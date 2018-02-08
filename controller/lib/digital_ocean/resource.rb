require_relative "api"

# Represents a resource in Digital Ocean's cloud.
class Resource
    include DigitalOcean

    def tag(name)
        tag(name, true)
    end

    def untag(name)
        tag(name, false)
    end

    def destroy!
        collection.delete(id: id)
    ensure
        @id = nil
    end

    protected

    def document
        collection.find(id: id)
    end

    def tag(name, action)
        digital_ocean.tags.create(DropletKit::Tag.new(name: name)) if action
        digital_ocean.tags.send(
            "#{action ? '' : 'un'}tag_resources",
            {name: name, resources: [{resource_id: id.to_s, resource_type: type}]}
        )
    end

end
