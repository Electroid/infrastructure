#! /bin/bash

cd /minecraft/server

if [[ $SERVER_ROLE == "PGM" ]]; then
	echo "PGM..."
	rm plugins/lobby.jar
elif [[ $SERVER_ROLE == "Lobby" ]]; then
	echo "Lobby..."
else
	echo "Mapdev... (not yet coded)"
fi

./start.sh