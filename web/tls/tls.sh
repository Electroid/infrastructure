#! /bin/bash

echo "Creating certificate..."
echo " > Name: $NAME"
echo " > Email: $EMAIL"
echo " > Domain: $DOMAIN"
echo " > Domains: $DOMAINS"

certbot certonly \
	--manual \
	--noninteractive \
	--agree-tos \
	--manual-public-ip-logging-ok \
	--preferred-challenges dns \
	--verbose \
	--manual-auth-hook ./tls-auth.sh \
	--manual-cleanup-hook ./tls-clean.sh \
	--email "$EMAIL" --domains "$DOMAINS"

echo "Printing certificate..."
certbot certificates

if [[ -n `kubectl get secret | grep $NAME-tls` ]]; then
	echo "Deleting old certificate..."
	kubectl delete secret $NAME-tls
fi

echo "Deploying new certificate..."
kubectl create secret tls $NAME-tls --key /etc/letsencrypt/live/$DOMAIN/privkey.pem --cert /etc/letsencrypt/live/$DOMAIN/fullchain.pem

echo "Done!"
