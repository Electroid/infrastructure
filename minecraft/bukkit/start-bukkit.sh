#! /bin/bash

cd /minecraft/server

# Bukkit needs this but Bungee doesn't? Very odd bug.
find . -name "*.yml" -type f -exec sh -c "envsubst < {} > env && rm {} && mv env {}" \;
find . -name "*.properties" -type f -exec sh -c "envsubst < {} > env && rm {} && mv env {}" \;
sleep 2 && mv commands.ignore commands.yml &

# Add default map if not connected to maps repo
if [ ! -d "/minecraft/maps" ]; then
  mkdir -p /minecraft/maps
  cp -R world /minecraft/maps/map
fi

# Also check to see if the folder is just empty
if [ -z "$(ls -A /minecraft/maps)" ]; then
  cp -R world /minecraft/maps/map
fi

# Make sure dropbox folder exists even if not enabled
if [ ! -d "/minecraft/dropbox" ]; then
  mkdir -p /minecraft/dropbox
fi

sh start.sh