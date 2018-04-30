require "stratus"

# Parse custom DNS queries into Kubernetes IP addresses.
module Minecraft
    module DNS
        class Parser
            def parse(query, servers)
                if components = parse_server_components(query, servers)
                    pod = components[:index] ? "#{components[:name]}-#{components[:index]}"
                                             : components[:name]
                    service = components[:name]
                    namespace = components[:datacenter] == "TM" ? "tm" : "default"
                    "#{pod}.#{service}.#{namespace}.svc.cluster.local"
                end
            end

            # Get the suffix that allows DNS queries to be processed. 
            def suffix
                "mc"
            end

            # Parse all of the sub-components of the DNS query
            # and return the best server that matches the query.
            def parse_server_components(query, servers)
                if components = parse_components(query)
                    servers = servers.select do |server|
                        server_name = server.bungee_name.downcase
                        server_name.include?(components[:name]) &&
                        (!components[:index] || server_name.include?((components[:index] + 1).to_s)) &&
                        (!components[:datacenter] || server.datacenter == components[:datacenter])
                    end
                    size = servers.size
                    if size == 0 || (!components[:selector] && size > 1)
                        raise ParseException, "#{servers.size} servers matched query\n(#{components})"
                    elsif size == 1
                        components[:server] = servers.first
                    else
                        components[:server] = case components[:selector]
                        when "rand"
                            servers[rand(0..size)]
                        when "empty"
                            servers.first
                        when "full"
                            servers.last
                        end
                    end
                    components[:datacenter] = components[:server].datacenter
                    unless components[:index]
                        unless components[:server].settings_profile == "private"
                            index = components[:server].bungee_name.gsub(/[^0-9]/, "")
                            unless index.empty?
                                components[:index] = [0, index.to_i - 1].max
                            end
                        end
                    end
                    components
                end
            end

            # Parse all of the sub-components of the DNS query.
            # Returns a hash containing the name, index, datacenter,
            # and selector of the query. Only name is gaurenteed to not be nil.
            def parse_components(query)
                parts = query.split(".").map{|part| part.downcase}
                size = parts.size
                if size > 1 && parts.last == suffix
                    name = parts[0]
                    index = nil
                    datacenter = nil
                    selector = nil
                    if size > 2
                        begin
                            parsed = parse_selector(parts[1])
                            if parsed.is_a?(Integer)
                                index = parsed
                            else
                                selector = parsed
                            end
                        rescue ParseException => e
                            raise e if size > 3
                            datacenter = parse_datacenter(parts[1])
                        end
                    end
                    if size > 3
                        datacenter = parse_datacenter(parts[2])
                    end
                    {
                        name: name,
                        index: index,
                        datacenter: datacenter,
                        selector: selector
                    }
                end
            end

            # Parse the server datacenter of the DNS query.
            # Can either be 'US', 'EU', or 'TM'. If a new
            # datacenter is added, it must be put on this list.
            def parse_datacenter(query)
                if query && ["us", "eu", "tm"].include?(query.downcase)
                    query.upcase
                else
                    raise ParseException, "Unable to parse datacenter from #{query}"
                end
            end

            # Parse the server selector of the DNS query.
            # Can be either an index, 'rand' for a random index,
            # 'empty' for the emptiest server, or 'full' for the
            # fullest server.
            def parse_selector(query)
                if query =~ /\d/
                    [0, query.to_i].max
                elsif query && ["rand", "empty", "full"].include?(query.downcase)
                    query.downcase
                else
                    raise ParseException, "Unable to parse #{query} into a selector"
                end
            end
        end
    end
end

# Represents an exception while parsing the
# special DNS query into a server ip address.
class ParseException < StandardError
end
