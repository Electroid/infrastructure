# Shift load path to controller files
$: << File.expand_path("../lib", __FILE__)

# Require nessecary libraries for the server
require "minecraft/server"

# Load the local server
@server = LocalServer.new("/minecraft")

# Response with a health check for a given method for server.
def check(method)
	value = @server.send(method.to_s)
	print "#{method.to_s}: #{value}"
	exit(value ? 0 : 1)
end

# Run different commands depending on argument
case arg = ARGV[0]
when "load!"
	@server.load!
when "ready?"
	# HACK: DNS script broke, so now we alternate between
	# server ordinals based on the day of the week.
	if @server.role_cache == "BUNGEE"
		# check(:dns_enabled)
		if @server.ensure_cache == "running"
			exit(0)
		elsif @server.ensure_cache == "stopping"
			exit(1)
		elsif Time.now.wday % 2 == @server.name_cache.split("-").last.to_i
			exit(0)
		else
			exit(1)
		end
	else
		check(:online)
	end
when "alive?"
	check(:alive?)
else
	raise "Unknown argument: #{arg}"
end
