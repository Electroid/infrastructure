require_relative "api"

# Represents a Droplet in Digital Ocean's cloud.
module Droplet
	include DigitalOcean

	def resource
		"droplet"
	end

	def ip
		@ip ||= networks_cache.v4.first.ip_address
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

	protected

	def create!
		create(id) # Insert logic to make specific node type
	end

	def create(name, script=Env.get("cloud_script") || "#! /bin/bash", tags=[], key=key.id, region=region.slug, size=size.slug, image=image.id)
		tags << (Env.get_multi("cloud_tags") || ["kubernetes"])
		droplet = DropletKit::Droplet.new(
			name: name,
			region: region,
			size: size,
			image: image,
			user_data: script,
			tags: tags,
			ssh_keys: [key],
			private_networking: true,
			ipv6: true,
			monitoring: true
		)
		droplet = collection.create(droplet)
		@id = droplet.id
		droplet
	end

	private

	def region(preferred=Env.get("cloud_region"))
		provider.regions.all
			.select {|region| region.available}
			.sort_by{|region| region.name == preferred}
			.first
	end

	def size(cpu=1, ram=1, high_cpu=false, region=region.slug)
		provider.sizes.all
			.select {|size| size.available &&
			 				size.regions.include?(region) &&
			 				(!high_cpu || size.slug.starts_with?("c"))}
			.sort_by do |size|
			 	ec = cpu; ac = size.vcpus; er = ram * 1024; ar = size.memory;
			 	ec == ac ? -1 : (ec < ac ? ac - ec : 0) +
			 	er == ar ? -1 : (er < ar ? ar - er : 0)
			end
			.first
	end

	def image(name=Env.get("cloud_image") || "ubuntu-16-04-x64", region=region.slug)
		provider.images.all
			.select {|image| image.regions.include?(region)}
			.sort_by{|image| image.slug == name || image.id == name ? -2 :
			  				 "#{image.distribution} #{image.name}".include?(name) ? -1 : 0}
			.first
	end

	def key(name=Env.get("cloud_ssh_key"))
		provider.ssh_keys.all
			.sort_by{|key| key.name == name}
			.first
	end

end
