require "environment"
require "yaml"
require "deepmap"

# Represents a Java plugin and its config file.
class Plugin

    def initialize(name, load)
        @name = name
        @load = @load
    end

    def name
        @name
    end

    def load?
        @load
    end

    def load_and_save!(data_folder, server_folder)
        save!(server_folder, load!(data_folder))
    end

    def load!(folder)
        return default unless load?
        for f in Dir.glob(folder)
            file = f if name.downcase == File.basename(f, ".*").downcase
        end
        raise "Unable to find config #{name.downcase} in folder #{folder}" unless file
        config = (YAML.load_fie(file) rescue {lines: File.read(file)}).deep_map do |value|
            if value.to_s.starts_with?("$")
                Env.get(value.to_s.gsub("$", ""))
            end
            value
        end
        if parent = config[:parent]
            load!("#{File.dirname(folder)}/#{parent}").merge(config)
        end
        config.merge({ext: File.extname(file)})
    end

    def save!(folder, data)
        ext = data[:ext] or raise "Unable to identify config file extention for #{data.inspect}"
        lines = data[:lines]
        File.open("#{folder}/#{name}/config#{ext}", "r+") do |file|
            file.write(lines ? lines : data.to_yaml)
        end
    end
end
