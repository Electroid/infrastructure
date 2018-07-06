require "recursive-open-struct"
require "environment"
require "rest-client"
require "mongoid"
require "json"

# Represents the RESTful API that interacts with the Stratus backend.
class Stratus

    # Generic base for implementing Stratus models.
    class Base < Stratus
        def initialize(route)
            @route = "/#{route}"
        end

        def route
            @route
        end

        # Update a model with the given partial document.
        def update(id, document)
            put("#{route}/#{id}", {document: document})
        end

        # Get a document based on ID or by the document's name.
        def by_id_or_name(idOrName)
            id?(idOrName) ? by_id(idOrName) : by_name(idOrName)
        end

        # Get a document by indexing the given name.
        def by_name(name)
            raise NotImplementedError, "Unable to index document by name"
        end

        # Get a document from its ID.
        def by_id(id)
            get("#{route}/#{id}")
        end

        # Get a list of documents given a hashed filter and other options.
        def search(filters={}, limit: nil, skip: nil)
            post("#{route}/search", {limit: limit, skip: skip}.merge(filters)).documents
        end
    end

    # Represents the API to interact with fetching and updating servers.
    class Servers < Base
        def initialize
            super("servers")
        end

        def by_name(name)
            get("#{route}/by_name/#{name}?bungee_name=true").documents.first
        end

        def restart(id, priority=0, reason="Automated restart queued")
            update(id, {restart_queued_at: Time.now, restart_reason: reason, restart_priority: priority})
        end

        def all
            search({offline: true, unlisted: true}, limit: 100)
        end
    end

    Server = Stratus::Servers.new

    # Represents the API to interact with user information.
    class Users < Base
        def initialize
            super("users")
        end

        def by_name(name)
            get("#{route}/by_username/#{name}") rescue nil
        end
    end

    User = Stratus::Users.new

    # Represents the API to interact with the current tournament data.
    class Tournaments < Base
        def initialize
            super("tournaments")
        end

        def search
            get("#{route}")
        end

        def current
            search.sort_by{|tm| tm.end ? Time.parse(tm.end) : Time.now}.last
        end
    end

    Tournament = Stratus::Tournaments.new

    protected

    # Check if a string is a legal ID.
    def id?(identifier)
        BSON::ObjectId.legal?(identifier)
    end

    def request(rest, url, payload, max_attempts=3, attempts=0, exception=nil)
        if attempts >= max_attempts
            raise "Unrecoverable HTTP #{rest} request exception: #{exception}\n" +
                  "(#{url}#{payload ? " with payload #{payload}" : ""})"
        end
        begin
            case rest
            when "GET"
                response = RestClient.get(url, options)
            when "PUT"
                response = RestClient.put(url, payload.to_json, options)
            when "POST"
                response = RestClient.post(url, payload.to_json, options)
            end
            json(response)
        rescue Exception => error
            sleep 1
            request(rest, url, payload, max_attempts, attempts + 1, error)
        end
    end

    # Send a POST request with an optional payload.
    def post(route, payload={})
        request("POST", url + route, payload)
    end

    # Send a PUT request with an optional payload.
    def put(route, payload={})
        request("PUT", url + route, payload)
    end

    # Send a simple GET request.
    def get(route)
        request("GET", url + route, nil)
    end

    Response = Class.new(RecursiveOpenStruct)

    # Parse a string response into a dynamic JSON object.
    def json(response)
        Response.new(JSON.parse(response), recurse_over_arrays: true)
    end

    # Get the default HTTP options for the REST client.
    def options
        @options ||= {
            accept: :json,
            content_type: :json,
            timeout: 3
        }
    end

    # Get the base URL of the Stratus API.
    def url
        @url ||= Env.get("api") || "localhost:3010"
    end

end
