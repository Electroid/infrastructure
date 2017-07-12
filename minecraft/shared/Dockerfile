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
ENV SERVER_STAGE=DEVELOPMENT
ENV SERVER_ID=null # Must be provided