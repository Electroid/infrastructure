FROM docker

# Install git packages
RUN apk update && apk upgrade && apk add bash git openssh curl

# Setup git identity
RUN git config --global user.email null@stratus.network
RUN git config --global user.name stratus

# Setup git environment variables
ENV GIT_URL=null
ENV GIT_CMD=uptime
ENV GIT_BRANCH=master
ENV GIT_TIME=15

# Copy and setup the git cron script
COPY . .
RUN chmod +x git.sh
CMD ./git.sh
