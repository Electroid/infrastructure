#! /bin/bash

# Delete old plugin jars, but keep folders
find /minecraft/server/plugins -maxdepth 1 -type f -delete

# Copy new plugin files while keeping persistent data
cp -R /minecraft/server-new/* /minecraft/server
cd /minecraft/server
rm -rf /minecraft/server-new

# Start the cloudy server
exec ./start-bukkit.sh