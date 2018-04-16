#! /bin/bash

echo "Starting $SERVER_ROLE server in $SERVER_STAGE..."
cd /minecraft/server

if [ -z "$SERVER_IDS" ]; then
	if [[ "$SERVER_ID" == "null" ]]; then
		echo "No server id specified... standalone mode"
		rm plugins/api-ocn.jar
	else
		echo "Selected single server id... $SERVER_ID"
	fi
else
	SERVER_IDS_ARRAY=(`echo $SERVER_IDS | sed 's/,/\n/g'`)
	SERVER_INDEX="${HOSTNAME: -1}"
	if [[ "$SERVER_SET" == "true" ]]; then
		for id in "${SERVER_IDS_ARRAY[@]}"; do
			if [[ $(curl -m 5 -s http://$SERVER_API_IP/servers/$id | jq .online) == "false" ]]; then
				export SERVER_ID="$id"
				echo "Selected set server id... $SERVER_ID"
				break
			fi
		done
		if [[ "$SERVER_ID" == "null" ]]; then
			echo "Could not find a possible server id for hostname... $HOSTNAME" && exit 1
		fi
	else
		export SERVER_ID="${SERVER_IDS_ARRAY[${SERVER_INDEX}]}"
		echo "Selected list server id at index $SERVER_INDEX... $SERVER_ID"
	fi
fi

if [ -e plugins/api-ocn.jar ]; then
	echo "Authenticating the server id with api..."
	for i in {1..5}; do
		export SERVER_DOCUMENT=$(curl -m 10 -s http://$SERVER_API_IP/servers/$SERVER_ID)
		if [ ! -z "$SERVER_DOCUMENT" ]; then
			break
		else
			echo " > Retry $i..."
			sleep 10
		fi
		echo "Unable to fetch server document with id... $SERVER_ID" && exit 1
	done
	export SERVER_NAME=$(echo $SERVER_DOCUMENT | jq .bungee_name | sed 's/\"//g')
	echo "Received server identity as $SERVER_NAME..."
else
	export SERVER_NAME="default"
fi

echo "Performing role specific commands..."
if [[ "$SERVER_ROLE" == "PGM" ]]; then
	rm plugins/lobby.jar
	if [[ "$SERVER_TOURNAMENT_ID" == "null" ]]; then
		rm plugins/tourney.jar
	fi
	if [[ "$SERVER_ROTATION" == "null" ]]; then
		export SERVER_ROTATION=$SERVER_NAME
	fi
	sed -i -e "s/!SERVER_ROTATION/${SERVER_ROTATION}/g" plugins/PGM/config.yml
	mkdir -p /minecraft/maps
	if [ -z "$(ls -A /minecraft/maps)" ]; then
		echo "Using fallback map since no repository was provided..."
		cp -R world /minecraft/maps/map
	fi
elif [[ "$SERVER_ROLE" == "LOBBY" ]]; then
	rm plugins/pgm.jar
	rm plugins/tourney.jar
	if [ -d "/minecraft/maps/lobby" ]; then
		rm -rf world
		cp -R /minecraft/maps/lobby world
	fi
elif [[ "$SERVER_ROLE" == "MAPDEV" ]]; then
	rm plugins/lobby.jar
	rm plugins/pgm.jar
	rm plugins/tourney.jar
fi

if [[ "$SERVER_SENTRY_DSN" == "null" ]]; then
	rm plugins/raven.jar
fi

if [[ "$SERVER_BUYCRAFT" == "null" ]]; then
	rm plugins/buycraft.jar
fi

echo "Injecting environment variables in configuration files..."
sed -i -e "s/!SERVER_ID/${SERVER_ID}/g" health.sh
sed -i -e "s/!SERVER_ID/${SERVER_ID}/g" plugins/API/config.yml
cp -R plugins/API plugins/API-OCN
for query in '*.yml' '*.yaml' '*.json' '*.properties'; do
	find . -name $query -type f -exec sh -c "echo ' > {}' && envsubst < {} > env && rm {} && mv env {}" \;
done

if [[ "$SERVER_REQUEST" == "true" ]]; then
	echo "Waiting for request sidecar to route traffic to $SERVER_PORT..."
	sleep 30
	while [[ $(curl -m 5 -s http://$SERVER_API_IP/servers/$SERVER_ID | jq .port) == "25555" ]]; do
		sleep 10
	done
	echo "Received signal to start server from requester..."
fi

echo "Starting the server daemon with $JAVA_OPTS..."
exec java -d64 -jar server.jar nogui -stage $SERVER_STAGE
