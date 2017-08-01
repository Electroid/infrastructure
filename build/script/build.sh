#! /bin/bash

# Login to docker
docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

# Split build information if given multiple
IFS=',' read -r -a FILES <<< $BUILD_FILES
IFS=',' read -r -a NAMES <<< $BUILD_NAMES

# Parse environment variables for build parameters
for INDEX in ${!FILES[@]}; do
	FILE="${FILES[INDEX]}"
	FILE_NAME="${FILE##*/}"
	FILE_PATH="${FILE%$FILE_NAME}"
	NAME="${BUILD_OWNER}/${NAMES[INDEX]}"
	# Build the image and push it to docker hub
	docker build -f $FILE_NAME -t $NAME $FILE_PATH && docker push $NAME
done
