class Env
    class << self

        def override
            @override ||= {}
        end

        def get(key, index=0)
            raw = override[key.upcase] || ENV[key.upcase]
            if raw != nil && !raw.empty? && raw != "null"
                values = raw.split(",") rescue []
                if index >= 0 && index < values.size
                    values[index]
                else
                    values
                end
            end
        end

        def get_multi(key)
            get(key, -1)
        end

        def has?(key, index=0)
            get(key, index) != nil
        end

        def set(key, value, force=false)
            if force || !has?(key)
                override[key.upcase] = value
            end
        end

        def host
            get("hostname") || "payload-0" # FIXME: remove after debugging done
        end

        def replica
            Integer(host.split("-").last) rescue 0
        end
    end
end
