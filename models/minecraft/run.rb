# Shift load path to controller files
$: << File.expand_path("../lib", __FILE__)

# Require nessecary libraries for the server
require "minecraft/server"

# Load the local server
server = LocalServer.new("/minecraft")

# Response with a health check for a given method for server.
def check(method)
	value = server.send(method.to_s)
	print "#{method.to_s}: #{value}"
	exit(value ? 0 : 1)
end

# Run different commands depending on argument
case arg = ARGV[0]
when "load!"
	server.load!
when "ready?"
	if server.role == "BUNGEE"
		check(:dns_enabled)
	else
		check(:online)
	end
when "alive?"
	check(:alive?)
else
	raise "Unknown argument: #{arg}"
end
