require "worker"
require "environment"
require "discordrb"

# Represents a Worker that includes a Discord bot integration.
class DiscordWorker < Worker

    def initialize(command="")
        bot(command)
        bot.run(:async)
        bot.online
        bot.update_status("Ready to go!", "Minecraft", nil)
    end

    def bot(command="")
        @bot ||= Discordrb::Commands::CommandBot.new(
            prefix: command.empty? ? "/" : "/#{command} ",
            client_id: Env.need("discord_client_id"),
            token: Env.need("discord_key"),
            log_mode: :quiet,
            supress_ready: true,
            parse_self: false,
            redact_token: true,
            ignore_bots: true
        )
    end

    protected

    def roles(name)
        bot.servers
           .values
           .map{|server| server.roles
                               .select{|role| role.name.downcase.include?(name.downcase)}
                               .map{|role| role.id}}
           .flatten!
    end

    def method_missing(m, *args, &block)
        bot.send(m, *args, &block)
    end
end
