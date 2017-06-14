#!/bin/bash

for file in *.yml; do envsubst < $file > $file; done
for file in *.json; do envsubst < $file > $file; done
envsubst < server.properties > server.properties

cat api.yml

mkdir plugins/API
cp api.yml plugins/API/config.yml
mkdir plugins/API-OCN
cp api.yml plugins/API-OCN/config.yml
mkdir plugins/PGM
cp pgm.yml plugins/PGM/config.yml
mkdir plugins/Commons
cp commons.yml plugins/Commons/config.yml
mkdir plugins/CommandBook
cp commandbook.yml plugins/CommandBook/config.yml
mkdir plugins/WorldEdit
cp worldedit.yml plugins/WorldEdit/config.yml

while true; do

cd /minecraft/server

# Update server files from remote repos
./update.sh

# Kill any other thread, just incase
pkill -f "sportbukkit"

# Run the java server
chmod +x sportbukkit.jar
sudo java -Xmx2G \
     -XX:+UseLargePages \
     -XX:+AggressiveOpts \
     -XX:+UseFastAccessorMethods \
     -XX:+OptimizeStringConcat \
     -XX:+UseBiasedLocking -Xincgc \
     -XX:MaxGCPauseMillis=50 \
     -XX:SoftRefLRUPolicyMSPerMB=10000 \
     -XX:+CMSParallelRemarkEnabled \
     -XX:ParallelGCThreads=5 \
     -Djava.net.preferIPv4Stack=true \
     -jar sportbukkit.jar nogui -stage $API_STAGE

echo "Starting in 5 seconds..."
sleep 5

done