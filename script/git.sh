#! /bin/bash

# Clone the repository from scratch
rm -rf data && git clone -b $GIT_BRANCH $GIT_URL data && cd data

# Wait a bit and always run the command on start
sleep $GIT_TIME && $GIT_CMD && echo "Waiting..."

while true; do
  # If any changes were made to the repository, pull and run the command
  if ! git diff --quiet remotes/origin/HEAD; then
    echo "Updating..." && git reset --hard origin/$GIT_BRANCH && git pull && $GIT_CMD
  fi
  sleep $GIT_TIME
done