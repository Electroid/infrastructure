require_relative "api"

# Represents a manifest of available Digital Ocean resources.
class Manifest
    include DigitalOcean

    def initialize
        cache
    end

    def get(key)
        indices[key] or raise "Unable to find resource by #{index} with #{key}"
    end

    def find(key)
        indices.select{|k,v| k.include?(key)}.map{|k,v| indices[k]}
    end

    protected

    def indices
        @indices ||= {}
    end

    def index
        raise "Must specify a field to index, or nil for none"
    end

    def document
        indices.clear
        for doc in docs = collection.all
            indices[doc.send("#{index}")] = doc
        end
        docs
    end

    def cache_duration
        6.hours
    end

    class << self
        def manifest
            @@manifest ||= self.new
        end

        def all
            manifest.cache.to_a
        end
    end

end
