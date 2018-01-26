require "droplet_kit"
require_relative "../document"

# Represents a resource in Digital Ocean's cloud.
module DigitalOcean
	include Document

	def initialize(id_or_name)
		@id = id_or_name
		@id = cache.id
	rescue
		@id = create!
	end

	def resource
		raise "Unable to find resource type (ie. 'droplet', 'floating_ip')"
	end

	def tag(name)
		tag(name, true)
	end

	def untag(name)
		tag(name, false)
	end

	def destroy!
		collection.delete(id: id)
		@id = nil
	end

	protected

	def create!
		raise "Unable to create new resource type of #{resource}"
	end

	def document
		collection.find(id: id)
	rescue
		collection.all.select{|resource| resource.name == id}.first
	rescue
		create!
	end

	def collection
		provider.send("#{resource}s")
	end

	def actions
		provider.send("#{resource}_actions")
	end

	def wait(action, backoff=10.seconds)
		case action.status
		when "in-progress"
			sleep(backoff)
			wait(provider.actions.find(id: action.id), backoff + 5.seconds)
		when "errored"
			raise "Action #{action.type} for #{action.resource_type} errored out"
		else
			action
		end
	end

	def locked?
		!actions.all.select{|action| action.status == "in-progress"}.empty?
	end

	def change(backoff=10.seconds)
		while locked?
			sleep(backoff)
			backoff = backoff + 5.seconds
		end
		if block_given?
			wait(yield)
		end
		refresh!
	end

	def tag(name, action)
		provider.tags.create(DropletKit::Tag.new(name: name)) if action
		provider.tags.send("#{action ? '' : 'un'}tag_resources", {name: name, resources: [{resource_id: id.to_s, resource_type: resource}]})
	end

	private

	def provider
		@provider ||= DropletKit::Client.new(access_token: Env.get("digital_ocean_access_token"))
	end

end
