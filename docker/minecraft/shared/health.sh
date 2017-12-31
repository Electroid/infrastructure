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
	if [[ "$(echo $document | jq .port)" == "25555" ]]; then
		echo "ok" && exit 0
	else
		if [ -z "$(mcstatus localhost:$SERVER_PORT ping)" ]; then
			echo "nok" && exit 1
		else
			echo "ok" && exit 0
		fi
	fi
fi
