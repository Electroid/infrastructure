require_relative "../resource"

# Represents a Droplet in Digital Ocean's cloud.
class Droplet < Resource

    def instantiate(resource)
        @id = resource.id
        document
    rescue
        @id = collection.create(resource).id
    end

    def resource_type
        "droplet"
    end

    def ip
        @ip ||= networks_cache.v4.first.ip_address # TODO: Change to internal
    end

    def online?
        status_cache == "active"
    end

    def offline?
        status_cache == "off" || status_cache == "archive"
    end

    def locked?
        locked || status_cache == "new"
    end

    def shutdown
        change{actions.shutdown(droplet_id: id)}
    rescue
        power_off
    end

    def reboot
        change{actions.reboot(droplet_id: id)}
    rescue
        power_on
    end 

    def power_on
        change{actions.power_on(droplet_id: id)}
    end

    def power_off
        change{actions.power_off(droplet_id: id)}
    end

    class << self
        def create!(name, size, tags=[])
            Droplet.new(
                DropletKit::Droplet.new(
                    name: name,
                    size: size,
                    tags: tags,
                    private_networking: true,
                    ipv6: true,
                    monitoring: true,
                    region: Region.get.slug,
                    image: Image.get.id,
                    ssh_keys: Keys.get.id.to_a,
                    user_data: Env.get("cloud_script")
                )
            )
        end
    end

end
