#! /bin/bash

cd /minecraft/server

# Bukkit needs this but Bungee doesn't? Very odd bug.
find . -name "*.yml" -type f -exec sh -c "envsubst < {} > env_temp && rm {} && mv env_temp {}" \;
find . -name "*.properties" -type f -exec sh -c "envsubst < {} > env_temp && rm {} && mv env_temp {}" \;

# Add default map if not connected to maps repo
if [ ! -d "/minecraft/maps" ]; then
  mkdir -p /minecraft/maps
  mv map /minecraft/maps/map
fi

exec ./start.sh