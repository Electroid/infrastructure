FROM git

# Install dependencies
RUN apk update && apk add python py-pip py-setuptools ca-certificates gettext
RUN pip install python-dateutil

# Download the s3cmd command line
RUN git clone https://github.com/s3tools/s3cmd.git s3cmd
RUN ln -s /s3cmd/s3cmd /usr/bin/s3cmd

# Add our custom configuration
ADD ./s3cfg /root/.s3cfg
ADD . /root

# Git related environment variables
ENV GIT_TIME=0
ENV GIT_CMD=/root/upload.sh
ENV GIT_URL=$BUCKET_GIT

# Inject custom secret variables
CMD find /root -name ".s3cfg" -type f -exec sh -c "envsubst < {} > env && rm {} && mv env {}" \; && exec ./git.sh
