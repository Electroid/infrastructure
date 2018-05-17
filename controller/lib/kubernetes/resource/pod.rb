require "kubernetes/resource"

# Represents a set of Docker containers in a Kubernetes cluster.
class Pod < Resource

    # Get a list of containers for this pod.
    def containers
        spec_cache.containers
    end

    # Run a block of code everything a message in logged in a container.
    def watch_container!(container_name=containers.first.name, &block)
        client.watch_pod_log(name, namespace, container: container_name, previous: true).each(block)
    end

    def fetch!
        cluster.get_pod(id)
    end

    def destroy!
        cluster.delete_pod(id)
    end
end
