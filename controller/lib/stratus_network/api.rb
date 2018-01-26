require "rest-client"
require "json"
require "recursive-open-struct"
require "mongoid"
require_relative "../linux/env"

class Stratus

	class Base < Stratus
  		def initialize(route)
  			@route = "/#{route}"
  		end

  		def route
  			@route
  		end

		def update(id, document)
			put("#{route}/#{id}", {document: document})
		end

		def by_id_or_name(idOrName)
			id?(idOrName) ? by_id(idOrName) : by_name(idOrName)
		end

		def by_name(name)
			raise NotImplementedError, "Unable to index document by name"
		end

		def by_id(id)
			get("#{route}/#{id}")
		end
	end

	class Server < Base
 		def initialize
  			super("servers")
  		end

		def by_name(name)
			get("#{route}/by_name/#{name}")
		end
	end

	class User < Base
  		def initialize
  			super("users")
  		end

		def by_name(name)
			get("#{route}/by_username/#{name}")
		end
	end

	protected

	def id?(identifier)
		BSON::ObjectId.legal?(identifier)
	end


	def put(route, payload={})
		request("PUT", url + route, payload)
	end

	def get(route)
		request("GET", url + route, nil)
	end

	def request(rest, url, payload, max_attempts=10, attempts=0)
		if attempts >= max_attempts
			raise "Unrecoverable HTTP #{rest} request exception " +
				  "(#{url}#{payload ? ' with payload #{payload}' : ''})"
		end
		begin
			case rest
			when "GET"
				response = RestClient.get(url, options)
			when "PUT"
				response = RestClient.put(url, payload.to_json, options)
			end
			json(response)
		rescue Errno::ECONNREFUSED,
			   Errno::EHOSTUNREACH,
			   Errno::EINVAL,
			   Errno::ECONNRESET,
			   Timeout::Error,
			   RestClient::NotFound
			sleep 30 # Back off before retrying request
			request(rest, url, payload, max_attempts, attempts + 1)
		rescue Exception => error
			print error
			sleep 60 # Longer back off because this is probably fatal
			request(rest, url, payload, max_attempts, max_attempts)
		end
	end

	def json(response)
		RecursiveOpenStruct.new(JSON.parse(response), recurse_over_arrays: true)
	end

	def options
		@options ||= {
			accept: :json,
			content_type: :json,
			timeout: 5
		}
	end

	def url
		@url ||= "localhost:3010" # Env.get("server_api_ip") || "api"
	end

end

