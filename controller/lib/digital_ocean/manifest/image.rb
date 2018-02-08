require_relative "../manifest"

# Manifest of all Digital Ocean droplet images.
class Image < Manifest

    protected

    def type
        "image"
    end

    def index
        "name"
    end

    class << self
        def get(name=Env.get("cloud_image"))
            manifest.find(name).sort.last
        end
    end

end
