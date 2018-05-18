require "kubernetes/resource"

# Represents a virtual machine in a Kubernetes cluster.
class Node < Resource

    # Determine if the node is ready to accepts pods and connections.
    def ready?
        status.conditions.select{|c| c.type == "Ready"}.map{|c| c.status == "True"}.first
    end

    # Get the last heartbeat time from the node.
    def last_heartbeat
        status.conditions.map{|c| Time.parse(c.lastHeartbeatTime)}.sort.last
    end

    # Get the list of labels for this node.
    def labels
        metadata.labels.to_h.map{|k,v| [k.to_s, v.to_s]}.to_h
    end

    # Patch new labels to the node.
    def label(values)
        cluster.patch_node(id, {metadata: {labels: values}})
    end

    # Get a list of pods that are on this node.
    def pods
        client.get_pods.select{|pod| pod.spec.nodeName == name}.map{|pod| Pod.new(pod.metadata.name)}
    end

    def fetch!
        cluster.get_node(id)
    end

    def destroy!
        cluster.delete_node(id)
    end
end
