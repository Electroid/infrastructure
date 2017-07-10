FROM maven

# Install other required packages
RUN apt-get update && apt-get install -y \
  patch \
  rake \
  software-properties-common \
  python-software-properties \
  apt-transport-https \
  ca-certificates

# Environment variables that are required
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000
ENV JENKINS_UC https://updates.jenkins.io
ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

# Set up persistent volume for configuration
VOLUME $JENKINS_HOME

# Make sure bundle is installed (for rake tasks)
RUN gem install bundle

# Install docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   "trusty" \
   stable"
RUN apt-get update && apt-get install -y docker-ce
RUN curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose
RUN docker-compose --version

# Install jenkins and tini (https://github.com/jenkinsci/docker)
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v0.14.0/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini && \
    echo "6c41ec7d33e857d4779f14d9c74924cab0c7973485d2972419a3b7c7620ff5fd /bin/tini" | sha256sum -c -
COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy
RUN curl -fsSL https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/2.60.1/jenkins-war-2.60.1.war -o /usr/share/jenkins/jenkins.war && \
    echo "34fde424dde0e050738f5ad1e316d54f741c237bd380bd663a07f96147bb1390 /usr/share/jenkins/jenkins.war" | sha256sum -c -
COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh
RUN chmod 0755 /usr/local/bin/jenkins.sh

# Setup git configuration (does not need to be changed)
RUN git config --global user.email "example@email.com"
RUN git config --global user.name "example"

# Expose ports and start the server
EXPOSE 50000
EXPOSE 8080
CMD ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]