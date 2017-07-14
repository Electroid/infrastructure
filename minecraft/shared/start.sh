#! /bin/bash

cd /minecraft/server
for query in '*.yml' '*.json' '*.properties'; do
	find . -name $query -exec sh -c "envsubst < {} > env_temp && rm {} && mv env_temp {}" \;
done
java -jar server.jar nogui -stage $SERVER_STAGE