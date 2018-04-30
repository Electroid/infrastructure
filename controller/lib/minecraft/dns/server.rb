require "minecraft/dns/manifest"
require "minecraft/dns/parser"
require "async/dns"

# Represents the custom DNS server that handles requests.
module Minecraft
    module DNS 
        class Server < Async::DNS::Server
            def initialize
                super([[:udp, "0.0.0.0", 2346]])
                @manifest = Manifest.new
                @parser = Parser.new
                @resolver = Async::DNS::Resolver.new([
                    [:udp, "8.8.8.8", 53],
                    [:tcp, "8.8.8.8", 53]
                ])
            end

            def process(name, resource_class, transaction)
                if response = @parser.parse(name, @manifest.servers)
                    transaction.respond!(response)
                else
                    transaction.passthrough!(@resolver)
                end
            end

            def run
                @manifest.run!
                super
            end
        end
    end
end
