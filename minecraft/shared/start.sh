#! /bin/bash

echo "Starting $SERVER_ROLE server in $SERVER_STAGE..."
cd /minecraft/server

echo "Performing role specific commands..."
if [[ "$SERVER_ROLE" == "PGM" ]]; then
	rm plugins/lobby.jar
	if [ -z "$SERVER_TOURNAMENT_ID" ]; then
		rm plugins/tourney.jar
	fi
elif [[ "$SERVER_ROLE" == "LOBBY" ]]; then
	rm plugins/pgm.jar
	if [ -d "/minecraft/maps/Lobby" ]; then
		rm -rf world
  		cp -R /minecraft/maps/Lobby world
	fi
elif [[ "$SERVER_ROLE" == "BUNGEE" ]]; then
	echo ""
else
	rm plugins/lobby.jar
	rm plugins/pgm.jar
	rm plugins/tourney.jar
fi

if [[ "$SENTRY_DSN_PLUGINS" == "null" ]]; then
	rm plugins/raven.jar
fi

if [ -z "$SERVER_IDS" ]; then
	if [[ "$SERVER_ID" == "null" ]]; then
		echo "No server id specified... standalone mode"
		rm plugins/api-ocn.jar
	else
		echo "Selected single server id... $SERVER_ID"
	fi
else
	IFS="," read -r -a SERVER_IDS_ARRAY <<< "$SERVER_IDS"
	SERVER_INDEX="${HOSTNAME: -1}"
	if [[ "$SERVER_INDEX" =~ ^-?[0-9]+$ ]]; then
		export SERVER_ID="${SERVER_IDS_ARRAY[${SERVER_INDEX}]}"
		echo "Selected list server id at index $SERVER_INDEX... $SERVER_ID"
	else
		for id in "${SERVER_IDS_ARRAY[@]}"; do
			if [[ $(curl -s http://$SERVER_API_IP:3010/servers/$id | jq .online) != "true" ]]; then
				export SERVER_ID="$id"
				echo "Selected set server id... $SERVER_ID"
				break
			fi
		done
		if [ -z "$SERVER_ID" ]; then
			echo "Could not find a possible server id for hostname... $HOSTNAME" && exit 1
		fi
	fi
fi

echo "Syncing both api configurations..."
sed -i -e "s/!SERVER_ID/${SERVER_ID}/g" health.sh
sed -i -e "s/!SERVER_ID/${SERVER_ID}/g" plugins/API/config.yml
cp -R plugins/API plugins/API-OCN

echo "Injecting environment variables in configuration files..."
for query in '*.yml' '*.yaml' '*.json' '*.properties'; do
	find . -name $query -type f -exec sh -c "echo ' > {}' && envsubst < {} > env && rm {} && mv env {}" \;
done

echo "Starting the server daemon with $JAVA_OPTS..."
exec java -d64 -jar server.jar nogui -stage $SERVER_STAGE
