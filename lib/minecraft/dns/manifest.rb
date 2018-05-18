require "worker/base"
require "stratus"

# Routinely update the list of Minecraft servers sorted by fullness.
module Minecraft
    module DNS
        class Manifest < Worker
            def run
                if servers = Stratus::Server.all
                             .sort_by{|s| (s.num_online || 0) / ([1, s.max_players || 0].max).to_f}
                    @servers = servers
                end
            end

            def servers
                @servers
            end
        end
    end
end