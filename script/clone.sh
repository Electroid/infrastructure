#! /bin/bash
# Usage: ./clone.sh {GitRepoName} {BuildCommand} {Test:false}

# Figure out which branch to use
if [ $# -lt 3 ]; then
  export GIT_BRANCH=$GIT_BRANCH_PRODUCTION
else
  export GIT_BRANCH=$GIT_BRANCH_TEST
fi

# Fetch git repo either locally or remotely
if [ $GIT_REMOTE ]; then
  if [ ! $GIT_CACHE ]; then
    # Download the version information from github to invalidate the Docker cache
    rm -rf $1 && curl -L "https://api.github.com/repos/$GIT_USER/$1/git/refs/heads/$GIT_BRANCH" -o $1.json && rm $1.json
  fi
  # Clone the remote repository
  git clone -b $GIT_BRANCH -- https://github.com/$GIT_USER/$1.git $1
else
  # Make sure the code folder exists
  # (although the host should have already put their code here)
  mkdir -p $1
fi

# Execute the build command
cd $1 && $2 && cd ..