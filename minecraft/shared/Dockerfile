FROM stratusnetwork/minecraft:base

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
ENV SERVER_RESTART=12h

# Required variables for each container
ENV SERVER_ID=null
ENV SENTRY_DSN_PLUGINS=null