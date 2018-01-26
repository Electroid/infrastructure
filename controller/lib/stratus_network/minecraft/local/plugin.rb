# Represents a Minecraft Java plugin to be loaded locally.
class Plugin

	def initialize(name, load_if)
		@jar = "plugins/#{name.downcase}.jar"
		@load = load_if
	end

	def load!
		unless @load
			File.delete(@jar)
		end
	end

end
