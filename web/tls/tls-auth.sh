#! /bin/bash

echo '{"type":"TXT","name":"_acme-challenge.!CERTBOT_DOMAIN","data":"!CERTBOT_VALIDATION","ttl":1,"priority":null,"port":null,"weight":null}' > request
sed -i -e "s/!CERTBOT_VALIDATION/${CERTBOT_VALIDATION}/g" request
PERIODS=`echo $CERTBOT_DOMAIN | grep -o "\." | wc -l`
if [[ "$PERIODS" == "1" ]]; then
	sed -i -e "s/!CERTBOT_DOMAIN/${CERTBOT_DOMAIN%$DOMAIN}/g" request
else
	sed -i -e "s/!CERTBOT_DOMAIN/${CERTBOT_DOMAIN%.$DOMAIN}/g" request
fi

echo "Creating DNS record..."
echo " > Request: $(cat request)"

RESPONSE=`curl -s -X POST -H "Content-Type: application/json" \
-H "Authorization: Bearer $DIGITAL_OCEAN_ACCESS_TOKEN" \
-d $(cat request) "https://api.digitalocean.com/v2/domains/$DOMAIN/records"`
echo " > Response: $RESPONSE"

RECORD_ID=`echo "$RESPONSE" | jq .domain_record.id`
echo "$RECORD_ID" > /tmp/CERTBOT_$CERTBOT_DOMAIN
echo "> ID: $RECORD_ID"

echo "Waiting for DNS propagation..."
sleep 10

echo "Done!"
