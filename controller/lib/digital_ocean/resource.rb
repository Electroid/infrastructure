require "droplet_kit"
require "document"
require "levenshtein"

# Extension for objects from the DigitalOcean API.
module ResourceKit
    class Resource
        include Document

        # Get the field of the resource to index this list by.
        # When calling #{get} or #{find}, this field will be
        # point of comparison for the query.
        def index
            raise NotImplementedError, "Must specify a field to index"
        end

        # Get a resource from the list given a query to the specific field #{index}.
        # Will throw an exception if not found, use #{find} for a safer search.
        def find_exact(key)
            cache[key] or raise "Unable to find resource by #{index} with #{key}"
        end

        # Find a list of resources given a query to the specific field #{index}
        def find_any(key="")
            cache.select{|k,v| key.empty? || k.to_s.include?(key.to_s)}
                 .sort_by{|k,v| [Levenshtein.distance(k, key.to_s), k[/\d+/].to_i * -1, k]}
                 .map{|k,v| find_exact(k)}
        end

        # Find the first resource that matches the query to the specific field #{index}
        def find_one(key)
            find_any(key).first rescue nil
        end

        # Find the first resource or throw an exception if nothing is found.
        def find_one_or_throw(key)
            find_one(key) or raise "Unable to find resource by #{index} with #{key}"
        end

        protected

        # Make the cache from the Document module a thread current variable.
        def cache
            Thread.current[:"#{self.class.name.downcase}_cache"] ||= super
        end

        def fetch!
            self.all.map{|resource| [resource.send("#{index}"), resource]}.to_h
        end

        def cache_duration
            1.hour
        end
    end
end

# Specific extensions for resources that need to be cachable and indexable.
module DropletKit
    class DropletResource
        def index
            "name"
        end
    end
    class ImageResource
        def index
            "name"
        end
    end
    class SSHKeyResource
        def index
            "name"
        end
    end
    class RegionResource
        def index
            "slug"
        end
    end
    class SizeResource
        def index
            "slug"
        end
    end
end
