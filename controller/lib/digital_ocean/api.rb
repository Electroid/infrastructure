require "droplet_kit"
require_relative "../system/document"

# Layer over the Digital Ocean API to interact with its cloud.
module DigitalOcean
    include Document

    protected

    def type
        raise "Unable to find resource type (ie. 'droplet', 'floating_ip')"
    end

    def collection
        digital_ocean.send("#{type}s")
    end

    def actions
        digital_ocean.send("#{type}_actions")
    end

    def wait(action, backoff=10.seconds)
        case action.status
        when "in-progress"
            sleep(backoff)
            wait(digital_ocean.actions.find(id: action.id), backoff + 5.seconds)
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

    private

    def digital_ocean
        @digital_ocean ||= DropletKit::Client.new(access_token: Env.get("digital_ocean_access_token"))
    end

end
