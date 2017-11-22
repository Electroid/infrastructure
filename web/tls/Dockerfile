FROM ubuntu:14.04
COPY . .
RUN apt-get update && \
	apt-get install -y software-properties-common && \
	add-apt-repository ppa:certbot/certbot && \
	apt-get update && \
	apt-get install -y certbot curl jq ca-certificates
ADD https://storage.googleapis.com/kubernetes-release/release/v1.7.4/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN set -x && \
    chmod +x /usr/local/bin/kubectl && \
    kubectl version --client
CMD ./tls.sh