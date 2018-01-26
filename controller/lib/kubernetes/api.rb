require "kubeclient"
require "celluloid/io"

module Kubernetes

	# TODO:
	# All of this code is still in a testing phase

	def cluster
		base = "..."
		@kubernetes ||= Kubeclient::Client.new(
			"https://158.69.120.199:6443/api/", "v1",
			ssl_options: {
		  		client_cert: OpenSSL::X509::Certificate.new(File.read("#{base}/client.crt")),
		  		client_key:  OpenSSL::PKey::RSA.new(File.read("#{base}/client.key")),
		  		ca_file:     "#{base}/ca.crt",
		  		verify_ssl:  OpenSSL::SSL::VERIFY_PEER
			},
			socket_options: {
				socket_class:     Celluloid::IO::TCPSocket,
  				ssl_socket_class: Celluloid::IO::SSLSocket
			},
			timeouts: {
				open: 60,
				read: 30
			}
		)
	end

	# TODO:
	# Restart set (patching deployment strategy)
	# Scale up sets
	# Scale up nodes

end

