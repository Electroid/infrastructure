#! /bin/bash

# Clone the repository from scratch
rm -rf data && git clone -b $GIT_BRANCH $GIT_URL data && cd data

# Wait a bit and always run the command on start
sleep $GIT_TIME && $GIT_CMD && echo "Waiting..."

# If any changes were made to the repository, pull and run the command
while true; do
  git fetch origin
  log=$(git log HEAD..origin/$GIT_BRANCH --oneline)
  if [[ "${log}" != "" ]] ; then
    echo "Updating..." && git merge origin/$GIT_BRANCH && $GIT_CMD
  fi
  sleep $GIT_TIME
done