require "worker/server"

class GenericWorker < ServerWorker

    instance("/server", "admin")

    def initialize(command, role)
        super(command)
        bot.command(:enable,
                    required_roles: roles(role),
                    min_args: 1,
                    max_args: 1,
                    usage: "#{command} enable [server]") do |event, name|
            server_up_or_down(true, event, name)
        end
        bot.command(:disable,
                    required_roles: roles(role),
                    min_args: 1,
                    max_args: 1,
                    usage: "#{command} disable [server]") do |event, name|
            server_up_or_down(false, event, name)
        end
    end

    def server_up_or_down(up, event, name)
        respond(event) do
            if server = Stratus::Server.by_name(name)
                if server_manage?(server)
                    if up
                        allocate(name)
                        "Server #{name} will be online in about two minutes!"
                    else
                        deallocate(name)
                        "Server #{name} will be offline momentarily!"
                    end
                else
                    "Unable to manage server '#{name}'"
                end
            else
                "Unable to find server '#{name}'"
            end
        end
    end

    def server_manage?(server)
        server.family != "bungee" || server.family != "tm"
    end
end
