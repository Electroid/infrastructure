#! /bin/bash

cd /minecraft/server

# Bukkit needs this but Bungee doesn't? Very odd bug.
find . -name "*.yml" -type f -exec sh -c "envsubst < {} > env && rm {} && mv env {}" \;
find . -name "*.properties" -type f -exec sh -c "envsubst < {} > env && rm {} && mv env {}" \;
sleep 2 && mv commands.ignore commands.yml &

exec ./start.sh