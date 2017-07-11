FROM stratusnetwork/minecraft:base

# Create working server directory
WORKDIR server

# Copy shared configurations
COPY . .

# Duplicate API config for minecraft and ocn versions
RUN cp -R plugins/API plugins/API-OCN

# Replace variables inside configuration files at the last moment
ONBUILD CMD find /minecraft/server -name '*.yml' -or -name '*.json' -or -name '*.properties' -exec envsubst < {} > {} \; 