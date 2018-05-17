require "environment"
require "yaml"
require "fileutils"

# Represents a Java plugin and its config file.
class Plugin

    def initialize(name, load)
        @name = name
        @load = load
    end

    def name
        @name
    end

    def load?
        @load
    end

    def load_and_save!(data_folder, server_folder)
        if data = load!(data_folder)
            save!(server_folder, data)
        else
            File.delete("#{server_folder}/#{name.downcase}.jar") rescue nil
        end
    end

    def load!(folder)
        return unless load?
        for f in Dir.glob("#{folder}/*")
            file = f if name.downcase == File.basename(f, ".*").downcase
        end
        unless file
            return load!("#{File.dirname(folder)}/base") if folder != "base"
            raise "Unable to find config #{name.downcase} in folder #{folder}"
        end
        config = if (ext = File.extname(file)) == ".yml"
            YAML.load_file(file)
        else
            {"lines" => File.read(file).to_s}
        end
        if parent = config["parent"]
            config = load!("#{File.dirname(folder)}/#{parent}").deep_merge(config)
        end
        config.merge({"ext" => ext})
    end

    def save!(folder, data)
        ext = data.delete("ext") or raise "Unable to get file extention for #{data.inspect}"
        lines = data.delete("lines")
        data.delete("parent")
        FileUtils.mkdir_p(directory = "#{folder}/#{name}")
        File.open("#{directory}/config#{ext}", "w") do |file|
            file.write(lines ? lines : data.to_yaml)
        end
    end
end
