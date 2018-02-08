require_relative "../manifest"

# Manifest of all Digital Ocean droplet sizes.
class Size < Manifest

    protected

    def type
        "size"
    end

    def index
        "slug"
    end

    class << self
        def find(name=Env.get("cloud_size"))
            manifest.find(name)
        end
    end

end
