require "droplet_kit"
require "environment"

# Extension for objects from the DigitalOcean API.
module DigitalOcean
    def digital_ocean
        @digital_ocean ||= DropletKit::Client.new(access_token: Env.need("digital_ocean_key"))
    end
end
