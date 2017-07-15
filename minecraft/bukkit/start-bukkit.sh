#! /bin/bash

cd /minecraft/server

# Bukkit needs this but Bungee doesn't? Very odd bug.
find . -name "*.yml" -type f -exec sh -c "envsubst < {} > env_temp && rm {} && mv env_temp {}" \;
find . -name "*.properties" -type f -exec sh -c "envsubst < {} > env_temp && rm {} && mv env_temp {}" \;

./start.sh