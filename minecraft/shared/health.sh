#! /bin/bash

if [[ "$SERVER_LOCAL" == "true" ]]; then
	echo "ok" && exit 0
fi

document=$(curl -s http://$SERVER_API_IP/servers/!SERVER_ID)

if [[ "$SERVER_ROLE" == "BUNGEE" ]]; then
	status=$(echo $document | jq .dns_enabled)
	if [[ "$status" == "true" ]]; then
		echo "ok" && exit 0
	elif [[ "$status" == "false" ]]; then
		echo "nok" && exit 1
	fi
else
	if [[ "$(echo $document | jq .current_port)" == "25555" ]]; then
		echo "ok" && exit 0
	else
		mcstatus localhost:$SERVER_PORT ping
	fi
fi
