require "lru_redux"
require_relative "linux/env"

# Encapsulates a cacheable object that is used internally.
module Document

	def id
		@id
	end

	def document
		raise "Unable to fetch document for object"
	end

	def cache
		(@cache ||= LruRedux::TTL::ThreadSafeCache.new(1, cache_duration.to_i)).getset(:document){document}
	end

	protected

	def cache_duration
		5.minutes
	end

	def refresh!
		@cache.clear
	end

	def method_missing(m, *args, &block)
		if m.to_s.end_with?("_cache")
			m = m.to_s.gsub("_cache", "")
		else
			refresh!
		end 
		cache.send(m, *args, &block)
	end

end
