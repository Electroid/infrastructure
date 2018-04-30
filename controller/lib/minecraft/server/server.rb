require "stratus"
require "minecraft/server/plugin"

# Represents the local Minecraft server that loads.
class LocalServer
    include Document

    def initialize(path)
        @path = path
    end

    def path
        @path
    end

    def id
        @id ||= Env.host.split("-").first
    end

    def fetch!
        server = Stratus::Server.by_id_or_name(id)
        unless @id == server._id
            @id = server._id
        end
        server
    end

    def load!
        raise "Unable to find data files to initialize server" if Dir.empty?("#{path}/data")
        for folder in ["base", role_cache == "BUNGEE" ? "bungee" : "bukkit"]
            FileUtils.copy_entry("#{path}/data/servers/#{folder}", "#{path}/server")
        end
        document.each{|k,v| Env.set(k, v, true)}
        [
            Plugin.new("API",         true),
            Plugin.new("Commons",     true),
            Plugin.new("PGM",         role_cache == "PGM"),
            Plugin.new("Lobby",       role_cache == "LOBBY"),
            Plugin.new("Channels",    role_cache != "BUNGEE"),
            Plugin.new("WorldEdit",   role_cache != "BUNGEE"),
            Plugin.new("CommandBook", role_cache != "BUNGEE"),
            Plugin.new("Tourney",     tournament_id_cache != nil),
            Plugin.new("Raven",       Env.has?("sentry_dsn")),
            Plugin.new("BuycraftX",   Env.has?("buycraft_key"))
        ].each do |plugin|
            plugin.load_and_save!(
                "#{path}/data/plugins/#{update_server_path_cache}",
                "#{path}/server/plugins"
            )
        end
        Dir.chdir("#{path}/server")
        if role_cache == "PGM"
            if Dir.empty?("#{path}/maps")
                File.symlink("world", "#{path}/maps/map")
            end
        elsif role_cache == "LOBBY"
            unless Dir.empty?("#{path}/maps/lobby") 
                File.delete("world")
                File.symlink("#{path}/maps/lobby", "world")
            end
        end
        FileUtils.copy_entry("plugins/API", "plugins/API-OCN")
    end

    def run!
        exec("java -d64 -jar server.jar nogui -stage #{Env.get('stage')}")
    end
end
