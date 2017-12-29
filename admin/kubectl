FROM alpine:3.6

ADD https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl /usr/local/bin/kubectl

ENV HOME=/config

RUN set -x && \
    apk add --no-cache bash curl jq ca-certificates && \
    chmod +x /usr/local/bin/kubectl && \
    \
    # Create non-root user (with a randomly chosen UID/GUI).
    adduser kubectl -Du 2342 -h /config && \
    \
    # Basic check it works.
    kubectl version --client

USER kubectl

ENTRYPOINT ["/usr/local/bin/kubectl"]
