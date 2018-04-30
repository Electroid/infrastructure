require "kubeclient"
require "celluloid/io"

# Represents an object that interacts with the Kubernetes cluster. 
module Kubernetes
    def cluster
        @config ||= Kubeclient::Config.read(File.expand_path("~/.kube/config"))
        unless @client
            context = @config.context
            ssl_options = context.ssl_options
            ssl_options[:verify_ssl] = 0
        end
        @client ||= Kubeclient::Client.new(
            context.api_endpoint,
            context.api_version,
            {
                ssl_options: ssl_options,
                auth_options: context.auth_options,
                socket_options: {
                    socket_class: Celluloid::IO::TCPSocket,
                    ssl_socket_class: Celluloid::IO::SSLSocket
                }
            }
        )
    end

    def nodes
        cluster.get_nodes.map{|node| Node.new(node.metadata.name)}
    end
end
