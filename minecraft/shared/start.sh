#! /bin/bash

cd /minecraft/server
find . -name '*.yml' -or -name '*.json' -or -name '*.properties' -exec envsubst < {} > {} \;
java -jar server.jar nogui -stage $SERVER_STAGE