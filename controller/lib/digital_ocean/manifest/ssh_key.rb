require_relative "../manifest"

# Manifest of all Digital Ocean ssh keys.
class Key < Manifest

    protected

    def type
        "ssh_key"
    end

    def index
        "id"
    end

    class << self
        def get(name=Env.get("cloud_key"))
            manifest.get(name)
        end
    end

end
