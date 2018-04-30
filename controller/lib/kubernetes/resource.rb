require "kubernetes/api"
require "document"

# Represents a resource in a Kubernetes cluster.
class Resource
    include Kubernetes
    include Document

    def initialize(name)
        @id = name
    end

    # Get the name of the resource.
    def name
        id
    end

    # Get the cached namespace of the resource.
    def namespace
        metadata_cache.namespace
    end

    # Block the current thread and proccess a block of code for every resource update.
    def watch!(&block)
        client.watch_events(namespace: namespace, field_selector: "involvedObject.name=#{name}").each(block)
    end

    def destroy!
        raise NotImplementedError, "Unable to delete a #{self.class.name} resource"
    end
end
