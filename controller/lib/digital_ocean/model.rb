require "digital_ocean/api"

# Extension for objects from the DigitalOcean API.
module DropletKit
    class BaseModel
        include ::DigitalOcean

        # Get the DigitalOcean client that sends requests on behalf of this model.
        def client
            digital_ocean
        end

        # Get the type of resource this model represents.
        def type
            raise NotImplementedError, "Undefined resource type (ie. droplet, floating_ip)"
        end

        # Get the object provider that manages the given type.
        def collection
            client.send("#{type}s")
        end

        # Get the action provider that manages the given type.
        def actions
            client.send("#{type}_actions")
        end

        # Fetch the newest version of this model and mass-assign all the new attributes.
        def refresh!
            self.attributes = collection.find(id: id).attributes
        end

        # Block the current thread until an action is completed.
        # An error will be raised if there is an exception with the action.
        def wait(backoff=1.second, action=nil)
            1.step do |i|
                break unless locked?
                sleep(backoff * 1.5 ** i)
            end
            case (action = block_given? ? yield : actions.find(id: action.id)).status
            when "in-progress"
                wait(backoff, action)
            when "errored"
                raise "Action #{action.type} for #{action.resource_type} errored out"
            else
                action
            end
        end

        # Check if any actions are currently in-progress for the given type.
        def locked?
            collection.actions(id: id).first.status == "in-progress"
        end

        # Tag the resource with the given name.
        # If the tag does not exist or the resource
        # already has the tag, it will be quietly handled.
        def tag(name)
            tag!(name, true)
        end

        # Untag the resource with the given name.
        def untag(name)
            tag!(name, false)
        end

        # Destroy the resource immediately, this is irreversible.
        def destroy!
            collection.delete(id: id)
        end

        protected

        def tag!(name, action)
            client.tags.create(DropletKit::Tag.new(name: name)) if action
            client.tags.send(
                "#{action ? '' : 'un'}tag_resources",
                {name: name, resources: [{resource_id: id, resource_type: type}]}
            )
        end
    end
end
