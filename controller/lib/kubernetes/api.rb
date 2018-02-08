require "kubeclient"
require "celluloid/io"
 
module Kubernetes
 
    # TODO:
    # All of this code is still in a testing phase
 
    def cluster
        @kubernetes ||= Kubeclient::Client.new(
            "https://192.168.99.100:8443/api/", "v1",
            ssl_options: {
                client_cert: OpenSSL::X509::Certificate.new(File.read('/Users/fun/.minikube/client.crt')),
                client_key:  OpenSSL::PKey::RSA.new(File.read('/Users/fun/.minikube/client.key')),
                ca_file:     '/Users/fun/.minikube/ca.crt',
                verify_ssl:  OpenSSL::SSL::VERIFY_PEER
            },
            socket_options: {
                socket_class: Celluloid::IO::TCPSocket,
                ssl_socket_class: Celluloid::IO::SSLSocket
            }
        )
    end
 
    # HACK: should be 'name' of droplet
    def name
        "minikube"
    end
 
    def node
        cluster.get_node(name) 
    end
 
    def labels
        node.metadata.labels.to_h.keys.map{|label| label.to_s}
    end
 
    # TODO:
    # Restart set (patching deployment strategy)
    # Scale up sets
    # Scale up nodes
 
end
