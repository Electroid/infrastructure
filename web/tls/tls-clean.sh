#! /bin/bash

if [ -f /tmp/CERTBOT_$CERTBOT_DOMAIN ]; then

	echo "Deleting DNS record..."

	RECORD_ID=$(cat /tmp/CERTBOT_$CERTBOT_DOMAIN)
	rm -f /tmp/CERTBOT_$CERTBOT_DOMAIN
	echo " > ID: $RECORD_ID"

	curl -s -X DELETE -H "Content-Type: application/json" \
		-H "Authorization: Bearer $DIGITAL_OCEAN_ACCESS_TOKEN" \
		"https://api.digitalocean.com/v2/domains/$DOMAIN/records/$RECORD_ID"

else

	echo "No DNS record found..."

fi

echo "Done!"
