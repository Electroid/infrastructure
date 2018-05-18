require "stratus"
require "document"
require "minecraft/protocol"
require "minecraft/server/plugin"

# Represents a local Minecraft server in a Docker container.
class LocalServer
    include Document

    def initialize(path=nil)
        @path = File.expand_path(path || "~")
    end

    # Get the absolute path that the server operates inside.
    def path
        @path
    end

    # Get the hostname of the container or unique ID of the server.
    def id
        @id ||= Env.host.split("-").first
    end

    # Find the server ID from the container hostname.
    def fetch!
        if server = Stratus::Server.by_id_or_name(id)
            unless @id == server._id
                @id = server._id
            end
            server
        else
            raise "Unable to find server using #{id}"
        end
    end

    # Move over files from the data folder, format plugin configuration files,
    # ensure at least one map available, and inject server variables into text-based files.
    def load!
        for folder in ["base", role_cache == "BUNGEE" ? "bungee" : "bukkit"]
            FileUtils.copy_entry("#{path}/data/servers/#{folder}", "#{path}/server")
        end
        [
            Plugin.new("API",         true),
            Plugin.new("Commons",     true),
            Plugin.new("PGM",         role_cache == "PGM"),
            Plugin.new("Lobby",       role_cache == "LOBBY"),
            Plugin.new("Channels",    role_cache != "BUNGEE"),
            Plugin.new("WorldEdit",   role_cache != "BUNGEE"),
            Plugin.new("CommandBook", role_cache != "BUNGEE"),
            Plugin.new("Tourney",     role_cache != "BUNGEE" && tournament_id_cache != nil),
            Plugin.new("Raven",       Env.has?("sentry_dsn")),
            Plugin.new("BuycraftX",   Env.has?("buycraft_secret"))
        ].each do |plugin|
            plugin.load_and_save!(
                "#{path}/data/plugins/#{update_server_path_cache}",
                "#{path}/server/plugins"
            )
        end
        FileUtils.mkdir_p("#{path}/maps") 
        if role_cache == "PGM" && Dir.entries("#{path}/maps").empty?
            FileUtils.mv("world", "#{path}/maps/map")
        elsif role_cache == "LOBBY" && Dir.exists?("#{path}/maps/lobby")
            FileUtils.rm_rf("world")
            FileUtils.mv("#{path}/maps/lobby", "world")
        end
        cache.to_h.each{|k,v| Env.set(k, v.to_s, true)}
        for file in ["yml", "yaml", "json", "properties"].flat_map{|ext| Dir.glob("#{path}/server/**/*.#{ext}")}
            data = Env.substitute(File.read(file))
            File.open(file, "w") do |f|
                f.write(data)
            end
        end
        FileUtils.copy_entry("#{path}/server/plugins/API", "#{path}/server/plugins/API-OCN")
    end

    # Check if the server is responding to pings.
    def alive?
        Minecraft::Protocol.safe_status != nil
    end
end
