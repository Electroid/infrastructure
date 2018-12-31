require "worker/discord"
require "stratus"

# Responds to Discord commands to spin-up Minecraft servers.
class ServerWorker < DiscordWorker

    def run
        servers_empty.each do |server|
            deallocate(server)
        end
        servers_unallocated.each do |server|
            server_down(server)
        end
    end

    def server_up(server, name)
        Stratus::Server.update(server._id, {ensure: "running"})
    end

    def server_down(server)
        Stratus::Server.update(server._id, {ensure: "stopping"})
    end

    def server_manage?(server)
        raise NotImplementedError
    end

    protected

    def respond(event)
        reply = begin
            ["\u274c", "#{yield}"]
        rescue Exception => e
            ["\u2705", "An exception occured while running your command!\n```#{e}```"]
        end
        event.react(reply.first)
        message.respond(reply.second)
    end

    def allocate(name)
        server = servers_next or raise "No servers left to allocate #{name}"
        log("Allocating old server #{server.name} for new server #{name}")
        server_up(server, name)
    end

    def deallocate(server)
        log("Deallocating server #{server}")
        server = server_restart(server)
        start = Time.now
        while Stratus::Server.by_id(server._id).online
            sleep(1)
            break if Time.now - start >= 30.seconds
        end
        server_down(server)
    end

    def servers
        Stratus::Server.all
                       .select{|server| server_manage?(server)}
                       .sort_by{|server| BSON::ObjectId.from_string(server._id).generation_time}
    end

    def servers_allocated
        servers.select{|server| server_is_allocated?(server)}
    end

    def servers_unallocated
        servers - servers_allocated
    end

    def servers_empty
        servers_allocated.select{|server| server.online && server.num_online <= 0}
    end

    def servers_next
        servers_unallocated.first rescue nil
    end

    def server_is_allocated?(server)
        server.ensure == "running"
    end

    def server_restart(server)
        Stratus::Server.restart(server._id, 100, "Server has been automatically deallocated")
    end

    def server_reset(server, name: nil, user: nil, lobby: false, priv: false, tm: false, index: 0, priority: nil)
        name = if user
            user.username
        elsif name == nil
            "Unknown-#{priority ? priority % 10 : Random.new.rand(99)}"
        else
            name
        end
        name_indexed = if indexed = index > 0
            if tm && !lobby
                "#{index < 10 ? "0" : ""}#{index}#{name.downcase}"
            else
                "#{name}-#{index}"
            end
        end
        bungee_name = (indexed ? name_indexed : name).downcase
        ip = if indexed
            "#{name.downcase}-#{index-1}.#{name.downcase}.#{tm ? "tm" : "default"}.svc.cluster.local"
        elsif user
            user._id
        else
            name.downcase
        end
        name = indexed ? name_indexed : name
        Stratus::Server.update(server._id, {
            name: name,
            bungee_name: bungee_name,
            ip: ip,
            priority: (priority || 0) + index,
            online: false,
            whitelist_enabled: !lobby && (priv || tm) ? true : false,
            settings_profile: priv || tm ? "private" : "",
            datacenter: tm ? "TM" : "US",
            box: tm ? "tournament" : "production",
            family: lobby ? "lobby" : "pgm",
            role: lobby ? "LOBBY" : "PGM",
            network: tm ? "TOURNAMENT" : "PUBLIC",
            visibility: "UNLISTED",
            startup_visibility: priv ? "UNLISTED" : "PUBLIC",
            realms: ["global", tm ? "tournament" : "normal"],
            operator_ids: user ? [user._id] : []
        })
    end
end
