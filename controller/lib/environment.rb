# Utility class to get access to environment variables.
class Env
    class << self
        # Get the value of a variable with a given key.
        # If an index is specified and the value is an
        # array, the value will be at the specified index.
        def get(key, index=0, splitter=",")
            raw = override[key.to_s.upcase] || ENV[key.to_s.upcase]
            if raw != nil && !raw.empty? && raw != "null"
                values = raw.split(splitter) rescue [raw]
                if index >= 0 && index < values.size
                    values[index]
                else
                    values
                end
            end
        end

        # Get an array of the values for the given key.
        def get_multi(key, splitter=",")
            get(key, -1, splitter)
        end

        # Determine whether the key has a value.
        def has?(key, index=0)
            get(key, index) != nil
        end

        # Override the value of an environment variable.
        def set(key, value, force=false)
            if force || !has?(key)
                override[key.to_s.upcase] = value
            end
        end

        # Get the name of the host, using environment variables.
        def host
            get("hostname")
        end

        # Determine if the host is replicated, -1 if unique.
        def replica
            Integer(host.split("-").last) rescue -1
        end

        # Get the hash of variables that override the system variables.
        def override
            @override ||= {}
        end

        # Get a hash of all variables including override.
        def all
            ENV.to_h.merge(override)
        end

        # Replace environment variable references with their actual values.
        def substitute(string)
            string.gsub(/\$\{([ a-zA-Z0-9_-]{1,})\b\}|\$([a-zA-Z0-9_-]{1,})\b/) do |var|
                get(var.gsub(/[\{\}\$]/, "")) or raise "Unable to find variable #{var} in '#{string}'"
            end
        end
    end
end
