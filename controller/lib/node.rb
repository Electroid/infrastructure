require "set"
require_relative "digital_ocean/resource/droplet"
require_relative "kubernetes/api"
require_relative "linux/connectable"
require_relative "linux/scheduleable"
 
class Node < Droplet
    include Kubernetes
    include Connectable
    include Scheduleable

    def instantiate(name, size)
        super(Droplet.create!(name, size))
        # run!
    end

    def task
        sync_tags_to_labels # Periodically pull tags from droplet and sync to the cluster
    end
 
    def tags
        super.map{|tag| "stratus.network/#{tag}"}.to_set
    end
 
    def labels
        super.select{|label| label.starts_with?("stratus.network")}.to_set
    end
 
    def sync_tags_to_labels
        expected = tags
        actual = labels
        patch = {}
        # Add keys that are defined as tags on the droplet,
        # but are not labels on the node.
        for key in expected
            unless actual.include?(key) 
                patch[key] = "true"
                # Delete keys of already synced labels
                # to prevent double-checking.
                actual.delete(key)
            end
        end
        # Check for labels that must be removed,
        # because there is no corresponding tag.
        for key in actual
            unless expected.include?(key)
                patch[key] = nil
            end
        end
        # Only send the patch if there are any changes.
        unless patch.empty?
            cluster.patch_node(name, {metadata: {labels: patch}})
        end
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
 
Env.set("digital_ocean_access_token", "1aa485fe12cc721e71fbf5fae80bb1e45961ae8a0211e530dc81ee41416d08af")
node = Node.new("testing", "512mb")
print node
