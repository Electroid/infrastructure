#! /bin/bash

# Clone the repository
git clone -b $GIT_BRANCH $GIT_URL data
cd data

# Ensure repository is in correct state (variables may have changed)
git pull && git reset --hard origin/$GIT_BRANCH && git pull

# Wait a bit and always run the command on start
sleep $GIT_TIME && $GIT_CMD && echo "Listening..."

# If any changes were made to the repository, pull and run the command
while true; do
  git fetch origin
  log=$(git log HEAD..origin/$GIT_BRANCH --oneline)
  if [[ "${log}" != "" ]] ; then
    git merge origin/$GIT_BRANCH && $GIT_CMD
    echo "Listening..."
  fi
  sleep $GIT_TIME
done