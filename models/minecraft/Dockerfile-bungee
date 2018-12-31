FROM minecraft:base

ARG BUNGEE_VERSION=1.12-SNAPSHOT
ADD $URL/tc/oc/bungeecord-bootstrap/$BUNGEE_VERSION/bungeecord-bootstrap-$BUNGEE_VERSION.jar server.jar

ARG VIA_VERSION=1.6.1-SNAPSHOT
add $MASTER_URL/us/myles/viaversion/$VIA_VERSION/viaversion-$VIA_VERSION.jar plugins/viaversion.jar

ADD $URL/tc/oc/api-ocn/$VERSION/api-ocn-$VERSION.jar plugins/api-ocn.jar
ADD $URL/tc/oc/api-bungee/$VERSION/api-bungee-$VERSION.jar plugins/api.jar
ADD $URL/tc/oc/commons-bungee/$VERSION/commons-bungee-$VERSION.jar plugins/commons.jar
ADD $URL/tc/oc/raven-bungee/1.11-SNAPSHOT/raven-bungee-1.11-SNAPSHOT.jar plugins/raven.jar
