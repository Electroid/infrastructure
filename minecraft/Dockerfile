FROM ubuntu:14.04

# Install software tools
RUN apt-get update && \
  apt-get install -y \
  default-jdk \
  software-properties-common \
  python-software-properties

# Retrieve custom java repository
RUN apt-get update && add-apt-repository ppa:webupd8team/java

# Install oracle java 8
RUN apt-get update && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && \
  apt-get install -y oracle-java8-installer

# Install packages
RUN apt-get update && apt-get install -y \
  screen \
  sshpass \
  git \
  maven \
  wget \
  curl \
  gettext-base

# Install maven 3.2.1
RUN wget https://archive.apache.org/dist/maven/maven-3/3.2.1/binaries/apache-maven-3.2.1-bin.tar.gz
RUN tar -zxf apache-maven-3.2.1-bin.tar.gz
RUN cp -R apache-maven-3.2.1 /usr/local
RUN unlink /usr/bin/mvn
RUN ln -s /usr/local/apache-maven-3.2.1/bin/mvn /usr/bin/mvn

# Create the minecraft folder
RUN mkdir minecraft
WORKDIR minecraft

# Git related arguments
ARG GIT_MAPS
ARG GIT_ROTATIONS
ARG GIT_PLUGINS

# Clone the maps repos
RUN git clone "$GIT_MAPS" maps

# Clone the rotations repo
RUN git clone "$GIT_ROTATIONS" rotations

# Clone the plugins repo
RUN git clone "$GIT_PLUGINS" plugins

# Copy the scripts to the container
COPY ./scripts server

# Copy the config files to the container
COPY ./config server

# Add background task to update server files
COPY ./config/crontab /etc/cron.d/crontab
RUN chmod 0644 /etc/cron.d/crontab
RUN touch /var/log/cron.log
CMD cron && tail -f /var/log/cron.log

# Start creating server files
WORKDIR server

# Install the latest sportbukkit
RUN curl -L "https://repo.extension.ws/service/local/artifact/maven/redirect?r=snapshots&g=tc.oc&a=sportbukkit&v=LATEST&e=jar" -o sportbukkit.jar

# Create a plugins folder
WORKDIR plugins

# Install pre-compiled plugins
RUN curl -L "https://repo.extension.ws/service/local/artifact/maven/redirect?r=snapshots&g=me.anxuiz&a=bukkit-settings&v=LATEST&e=jar" -o settings.jar
RUN curl -L "https://repo.extension.ws/service/local/artifact/maven/redirect?r=snapshots&g=com.github.rmsy.Channels&a=Channels&v=LATEST&e=jar" -o channels.jar
RUN curl -L "https://dev.bukkit.org/projects/worldedit/files/latest" -o worldedit.jar

# Install not-yet-compiled plguins
WORKDIR ..
RUN ./update.sh true

# Start the minecraft server
EXPOSE 25565
ENTRYPOINT ["/bin/bash", "./run.sh"]