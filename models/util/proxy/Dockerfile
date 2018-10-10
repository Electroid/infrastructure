FROM haproxy:1.5-alpine

RUN apk add gettext --no-cache

# Copy files over to the container
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

# Port for players will connect (client ip will be passed through)
ENV PROXY_PORT=null

# Port that acts as a passthrough (client ip will be masked) 
ENV PASSTHROUGH_PORT=null

# Port that the server is running on (proxy protocol should be enabled)
ENV INTERNAL_PORT=null
ENV INTERNAL_HOST=null

# Inject environment variables and start haproxy
CMD find /usr/local/etc/haproxy -name "haproxy.cfg" -type f -exec sh -c "envsubst < {} > env && rm {} && mv env {}" \; && haproxy -f /usr/local/etc/haproxy/haproxy.cfg
