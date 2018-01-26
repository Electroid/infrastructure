require "lru_redux"
require_relative "../../api"
require_relative "../../../document"

class LocalServer
	include Document

	def api
		@api ||= Api::Server.new
	end

	def id
		@id ||= api.by_id_or_name(
			Env.get("server_id", Env.replica) ||
			"#{Env.host.split("-").first}#{Env.replica + 1}"
		).documents.first._id
	end

	def document
		api.by_id(id)
	end

	def load!
		# Make sure server id can be read as an environment variable
		Env.set("server_id", id)
		# Perform specific tasks for a server role
		if role_cache == "PGM"
			Env.set("server_rotation", bungee_name_cache)
			# Use the default map if no maps are defined
			if Dir.empty?("/minecraft/maps")
				File.rename("world", "/minecraft/maps/map")
			end
		elsif role_cache == "LOBBY"
			# Copy the lobby into the server folder if defined
			unless Dir.empty?("/minecraft/maps/lobby") 
				File.delete("world")
				File.symlink("/minecraft/maps/lobby", "world")
			end
		end
		# Load all the plugins given a server role and variables
		[Plugin.new("lobby",    role_cache == "LOBBY"),
		 Plugin.new("pgm", 	    role_cache == "PGM"),
		 Plugin.new("tourney",  role_cache == "PGM" && datacenter_cache == "TM"),
		 Plugin.new("raven",    Env.has?("server_sentry_dsn")),
		 Plugin.new("buycraft", Env.has?("server_buycraft"))].each do |plugin|
		 	plugin.load! # Will delete plugins that are not permitted to be loaded
		end
		# Inject environment variables into configurations
		for ext in ["yml", "yaml", "json", "properties"]
			for config in Dir.glob("/minecraft/server/**/*.#{ext}")
				result = system(Env.override, "envsubst < #{config} > env && rm #{config} && mv env #{config}")
				print " > #{config} ... #{result}"
			end
		end
	end

	def run!
		exec("java -d64 -jar server.jar nogui -stage #{Env.get('server_stage')}")
	end

end
