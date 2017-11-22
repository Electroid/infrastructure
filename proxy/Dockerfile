FROM haproxy:1.5-alpine

RUN apk add gettext --no-cache

# Copy files over to the container
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

# Proxy environment variables
ENV PROXY_EXTERNAL_PORT=null
ENV PROXY_INTERNAL_PORT=null
ENV PROXY_HOST=null

# Inject environment variables and start haproxy
CMD find /usr/local/etc/haproxy -name "haproxy.cfg" -type f -exec sh -c "envsubst < {} > env && rm {} && mv env {}" \; && haproxy -f /usr/local/etc/haproxy/haproxy.cfg
