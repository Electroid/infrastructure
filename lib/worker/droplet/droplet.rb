require "worker"
require "document"
require "stratus"
require "digital_ocean"

# Listens to changes in server documents and allocates droplets.
class DropletWorker < Worker
    include DigitalOcean
    include Document

    def initialize(attributes)
        @attributes = attributes
    end

    # Cache a manifest of droplets and servers for the worker to query.
    def fetch!
        servers = servers_fetch
        droplets = droplets_fetch
        servers_to_droplet = servers.map{|server| [
            server,
            (droplets.select{|droplet| droplet.id.to_s == server.status}.first rescue nil)
        ]}.to_h
        {
            droplets: droplets,
            droplets_to_server: servers_to_droplet.invert,
            servers: servers,
            servers_to_droplet: servers_to_droplet
        }
    end

    # Periodically check servers to determine if any droplets need to be scaled.
    def run
        servers.each do |server|
            droplet = server_to_droplet(server)
            if !droplet
                if server.status && (server.status.to_i rescue 1) > 0
                    scale_fix(server)
                elsif server.ensure == "running"
                    scale_up(server)
                end
            elsif server.ensure == "stopping"
                scale_down(server)
            end
        end
        droplets.each do |droplet|
            if droplet_can_delete?(droplet) && droplet.tags.include?("delete")
                log("Destroying the queued Droplet #{droplet.name}")
                droplet.destroy!
            end
        end
    end

    # Create a new droplet for the given server.
    def scale_up(server)
        raise "Droplet already exists for #{server.name}" if server_to_droplet(server)
        log("Creating a Droplet for #{server.name}")
        if droplet = droplet_create(@attributes.merge({name: server.bungee_name}))
            server_set_droplet(server, droplet)
            droplet.untag("delete")
        end

    end

    # Shutdown and destroy the droplet for the given server.
    def scale_down(server)
        raise "Droplet does not exist for #{server.name}" unless droplet = server_to_droplet(server)
        if droplet_can_delete?(droplet)
            log("Deleting the Droplet for #{server.name}")
            droplet.destroy!
        else
            log("Queuing the Droplet for #{server.name} to be deleted before its next billable hour")
            droplet.tag("delete")
        end
        server_set_droplet(server, nil)
    end

    # Remove any ensure commitments for the given server.
    # This can occur when the droplet is deleted outside the worker.
    def scale_fix(server)
        raise "Server #{server.name} is not assigned a Droplet to fix" unless server.status
        log("Removing #{server.ensure} ensure from #{server.name} because Droplet was externally deleted")
        server_set_ensure(server, nil)
        server_set_droplet(server, nil)
    end

    protected

    def cache_duration
        10.seconds
    end

    def servers
        cache[:servers]
    end

    def servers_fetch
        Stratus::Server.all
    end

    def server_to_droplet(server)
        cache[:servers_to_droplet][server]
    end

    def server_set_droplet(server, droplet)
        Stratus::Server.update(server._id, {status: droplet ? droplet.id.to_s : nil})
        refresh!
    end

    def server_set_ensure(server, status)
        Stratus::Server.update(server._id, {ensure: status})
        refresh!
    end

    def droplets
        cache[:droplets]
    end

    def droplets_fetch
        digital_ocean.droplets.all.to_a
    end

    def droplet_to_server(droplet)
        cache[:droplets_to_server][droplet]
    end

    def droplet_can_delete?(droplet)
        (Time.now - Time.parse(droplet.created_at)) % 1.hour >= (1.hour - 5.minutes)
    end

    def droplet_create(name:, image:, region:, size:, ssh_key:, tags: [], script_path: nil)
        if exists = digital_ocean.droplets.find_one(name)
            return exists
        end
        image = digital_ocean.images.find_one_or_throw(image)
        region = digital_ocean.regions.find_one_or_throw(region)
        unless image.regions.include?(region.slug)
            raise "Image #{image.name} is not avaiable in the #{region.name} region"
        end
        size = digital_ocean.sizes.find_one_or_throw(size)
        unless region.sizes.include?(size.slug)
            raise "Size #{size.slug} is not avaiable in the #{region.name} region"
        end
        if size.disk < image.min_disk_size
            raise "Size #{size.slug} does not have enough disk space for the #{image.name} image"
        end
        ssh_key = digital_ocean.ssh_keys.find_one_or_throw(ssh_key)
        script = script_path ? File.read(script_path).to_s : ""
        droplet = digital_ocean.droplets.create(DropletKit::Droplet.new(
            name: name,
            region: region.slug,
            size: size.slug,
            image: image.id,
            ssh_keys: [ssh_key.id],
            tags: tags,
            user_data: script,
            ipv6: true,
            private_networking: true,
            monitoring: true
        ))
        refresh!
        droplet
    end
end
