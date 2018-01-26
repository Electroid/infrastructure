require_relative "linux/machine"
require_relative "digital_ocean/droplet"
require_relative "kubernetes/api"
require_relative "schedule"

class Node
	include Machine
	include Droplet
	include Kubernetes
	include Schedule

	def task
		# tag_sync
		cluster.get_nodes
	end

	def tag_sync
		expected = tags
		actual = cluster.get_node(name)
		print expected
		print actual
	end

	# General

	# --------

	# Minecraft

	# Scheduled:
	# - Create new node for transfer
	# - Switch labels so next pod opens on new node
	# - Queue pod restart at scheduled time
	# - Delete old new to finish transfer

	# Scaling:
	# - Override DNS to route to busiest server
	# - Create new node if at capacity and scale pods
	# - Delete node when no connections are left and end of hour
	# - Potentially create new server object if none exists

	# Dynamic:
	# - Spoof DNS to fake server to verify permission
	# - Monitor for dynamic threshold (ie. # of players)
	# - Create new node with pod and set expiry time
	# - Shut down node if time meet or empty at end of hour

	# Website

	# Wait for deployments and rolling restarts by patching deployments
	# Sync Droplet labels to Kubernetes labels

end

node = Node.new("lobby")
node.task

