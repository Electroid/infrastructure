#! /bin/bash

if [[ "$SERVER_LOCAL" == "true" ]]; then
	echo "ok" && exit 0
fi

status=`curl -s http://$SERVER_API_IP:3010/servers/!SERVER_ID | jq .dns_enabled`
if [[ "$status" == "true" ]]; then
	echo "ok" && exit 0
elif [[ "$status" == "false" ]]; then
	echo "nok" && exit 1
fi
