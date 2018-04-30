require "lru_redux"
require "active_support/time"

# Represents an object that has an unique ID and a cachable document.
module Document

    # Get the ID of this document.
    # Must be set by the implementer using @id = "value".
    def id
        @id
    end

    # Gets a new version of the document and updates the cache.
    def document
        cache_internal[:document] = fetch!
    end

    # Get a cached version of the document or call #{fetch!}
    # if the cache has expired beyond the #{cache_duration}.
    def cache
        cache_internal.getset(:document){fetch!}
    end

    # Fetch the newest version of the document.
    # This does not update the cache, use #{document} instead. 
    def fetch!
        raise NotImplementedError, "Unable to fetch document"
    end

    # Clear the document cache and fetch the newest document.
    def refresh!
        cache_internal.clear
        cache
    end

    protected

    # Duration that document caches should be stored before expiring.
    def cache_duration
        5.minutes
    end

    # Cache provider that allows thread-safe ttl operations.
    def cache_internal
        @cache ||= LruRedux::TTL::ThreadSafeCache.new(1, cache_duration.to_i)
    end

    # Any missing methods are assumed to be directed at the document.
    # If the method ends with "_cache", then the method is forwarded
    # to the cache, if not it forwards to a newly requested document.
    def method_missing(m, *args, &block)
        if m.to_s.end_with?("_cache")
            m = m.to_s.gsub("_cache", "")
        else
            refresh!
        end 
        cache.send(m, *args, &block)
    end
end
