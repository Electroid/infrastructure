#! /bin/bash

# Gitlab maps
cd ../maps
git pull

# Github rotations
cd ../rotations
git pull

# ProjectAres plguins
cd ../plugins
if ${1:-false} || ! git diff --quiet remotes/origin/HEAD; then
	# If there are changes, re-compile the plugins
	git pull
	mvn clean package -DskipTests=true
	mv PGM/target/PGM-1.11-SNAPSHOT.jar ../server/plugins/pgm.jar
	mv Commons/bukkit/target/commons-bukkit-1.11-SNAPSHOT.jar ../server/plugins/commons.jar
	mv API/bukkit/target/api-bukkit-1.11-SNAPSHOT.jar ../server/plugins/api.jar
	mv API/ocn/target/api-ocn-1.11-SNAPSHOT.jar ../server/plugins/api-ocn.jar
	cd ../server
fi