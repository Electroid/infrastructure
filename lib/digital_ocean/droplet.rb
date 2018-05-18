require "connectable"
require "digital_ocean/model"

# Extension for Droplet actions.
module DropletKit
    class Droplet
        include Connectable

        # Check if this droplet is online.
        def online?
            status == "active"
        end

        # Check if this droplet is offline or archived.
        def offline?
            status == "off" || status == "archive"
        end

        # Check if this droplet is locked by an action or
        # is in the progress of being created.
        def locked?
            locked || status == "new"
        end

        # Gracefully shutdown this droplet and force power
        # off if the previous action fails. 
        def shutdown
            wait{actions.shutdown(droplet_id: id)}
        rescue
            power_off
        end

        # Gracefully reboot this droplet and force power
        # on if the previous action fails.
        def reboot
            wait{actions.reboot(droplet_id: id)}
        rescue
            power_on
        end 

        # Turn on this droplet.
        def power_on
            wait{actions.power_on(droplet_id: id)}
        end

        # Forcefully turn off this droplet.
        def power_off
            wait{actions.power_off(droplet_id: id)}
        end

        def ip
            public_ip
        end

        def destroy!
            shutdown
            super
        end

        def type
            "droplet"
        end
    end
end
