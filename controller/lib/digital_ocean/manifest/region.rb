require_relative "../manifest"

# Manifest of all Digital Ocean regions.
class Region < Manifest

    protected

    def type
        "region"
    end

    def index
        "slug"
    end

    class << self
        def get(name=Env.get("cloud_region"))
            manifest.find(name)
        end
    end

end
