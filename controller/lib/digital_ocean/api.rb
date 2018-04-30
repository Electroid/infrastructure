require "droplet_kit"

# Extension for objects from the DigitalOcean API.
module DigitalOcean
    def digital_ocean
        @digital_ocean ||= DropletKit::Client.new(access_token: Env.get("digital_ocean_key"))
    end
end
