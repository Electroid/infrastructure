require "worker/server"

class GenericWorker < ServerWorker

    def initialize
        super
        bot.command(:server,
                    required_roles: roles("admin"),
                    min_args: 1,
                    max_args: 1,
                    usage: "/enable [server]") do |event, name|
            respond(event) do
                allocate(name)
                "Server #{name} has been allocated and will be online in a few minutes!"
            end
        end
    end

    def server_manage?(server)
        server.family == "pgm"
    end

    def server_up(server, name)
        user = Stratus::User.by_name(name)
        server_reset(server,
            name: user ? nil : name,
            user: user,
            priority: 200 + (server.priority % 10),
            priv: true,
            status: "running"
        )
    end

    def server_down(server)
        server_reset(server,
            name: "Private",
            priority: 200 + (server.priority % 10),
            priv: true,
            status: "stopping"
        )
    end
end
