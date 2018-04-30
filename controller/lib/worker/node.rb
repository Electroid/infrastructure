require "worker/base"
require "kubernetes/all"
require "digital_ocean/all"

# Ensures that Nodes are healthy and synced with Droplets.
class NodeWorker < Worker
    include DigitalOcean
    include Kubernetes

    def run
    	droplets = digital_ocean.droplets.all.map{|droplet| [droplet.name, droplet]}.to_h
        nodes.each do |node|
            droplet = droplets[node.name]
            if !droplet
                log("Destroying #{node.name} node since its Droplet is missing")
                node.destroy!
            elsif (offline = Time.now - node.last_heartbeat) >= 15.minutes
                log("Deleting #{droplet.name} droplet because its been offline for too long")
                droplet.destroy!
            elsif offline >= 5.minutes
                log("Rebooting #{droplet.name} droplet because its heartbeat is not responding")
                droplet.reboot
            end 
        end
    end
end
