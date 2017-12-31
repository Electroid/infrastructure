#! /bin/bash

if [[ "$SERVER_LOCAL" == "true" ]]; then
	echo "ok"
else
	curl -s -m 3 -X PUT -H 'Content-Type: application/json' -H 'Accept: application/json' \
	-d '{"document":{"online":false},"id":"!SERVER_ID","server":{}}' \
	http://$SERVER_API_IP/servers/!SERVER_ID
	echo "ok"
fi
