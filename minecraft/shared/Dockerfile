FROM stratusnetwork/minecraft2

# Create working server directory
WORKDIR server

# Copy shared configurations
COPY . .

# Duplicate API config for minecraft and ocn versions
RUN cp -R plugins/API plugins/API-OCN

# Give run access to the start script
RUN chmod +x start.sh

# Shared variables
ENV SERVER_STAGE=PRODUCTION
ENV SERVER_BACKEND_IP=db.stratus.network
ENV SERVER_WEB_IP=db.stratus.network
ENV SERVER_PORT=25565
ENV SERVER_PUBLISH=true
ENV SERVER_SIGNAL=0
ENV SERVER_REPORTS=['pgm', 'lobby']
ENV SERVER_CROSS=true

# Required variables for each container
ENV SERVER_ID=null
ENV SENTRY_DSN_PLUGINS=null

# Escape variable to avoid being substituted
ENV ESCAPE=$

# Healthcheck to ensure the server is running properly
HEALTHCHECK --start-period=60s --interval=15s --timeout=10s CMD mcstatus localhost:$SERVER_PORT ping