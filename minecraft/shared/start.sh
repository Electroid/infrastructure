#! /bin/bash

echo "Starting $SERVER_ROLE server in $SERVER_STAGE..."
cd /minecraft/server

echo "Removing Tourney plugin..."
rm plugins/tourney.jar

echo "Performing role specific commands..."
if [[ $SERVER_ROLE == "PGM" ]]; then
	echo "Removing Lobby plugin..."
	rm plugins/lobby.jar
elif [[ $SERVER_ROLE == "LOBBY" ]]; then
	echo "Removing PGM plugin..."
	rm plugins/pgm.jar
elif [[ $SERVER_ROLE == "BUNGEE" ]]; then
	echo "..."
else
	echo "Mapdev server is not supported yet!"
	exit 1
fi

echo "Injecting environment variables in configuration files..."
for query in '*.yml' '*.yaml' '*.json' '*.properties'; do
	find . -name $query -type f -exec sh -c "echo ' > {}' && envsubst < {} > env_temp && rm {} && mv env_temp {}" \;
done

echo "Starting the server daemon with $JAVA_OPTS..."
exec java -d64 -jar server.jar nogui -stage $SERVER_STAGE