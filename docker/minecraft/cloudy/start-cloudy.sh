#! /bin/bash

# Delete old plugin jars, but keep folders
find /minecraft/server/plugins -maxdepth 1 -type f -delete

# Copy new plugin files while keeping persistent data
cp -R /minecraft/server-new/* /minecraft/server
cd /minecraft/server
rm -rf /minecraft/server-new

# Ensure new api-ocn config is copied
rm /minecraft/server/plugins/API-OCN/config.yml 
cp /minecraft/server/plugins/API/config.yml /minecraft/server/plugins/API-OCN/config.yml 

# Start the cloudy server
exec ./start-bukkit.sh
