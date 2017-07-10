FROM ruby:2.1.10

# Install software tools
RUN apt-get update && \
  apt-get install -y \
  software-properties-common \
  python-software-properties \
  apt-transport-https \
  ca-certificates \
  screen \
  python-pip \
  git \
  maven \
  wget \
  curl \
  gettext-base \
  rake

# Retrieve custom java repository
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

# Install oracle java 8
RUN apt-get update && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
  apt-get install -y oracle-java8-installer

# Install gradle 4
RUN wget https://services.gradle.org/distributions/gradle-4.0.1-bin.zip && \
  mkdir /opt/gradle && \
  unzip -d /opt/gradle gradle-4.0.1-bin.zip
ENV PATH=$PATH:/opt/gradle/gradle-4.0.1/bin

# Install mcstatus for healthchecks
RUN pip install mcstatus

# Create the minecraft folder
RUN mkdir minecraft
WORKDIR minecraft

# Compile plugins for Bukkit and Bungee
WORKDIR build
RUN git config --global user.email "minecraft@docker.com"
RUN git config --global user.name "minecraft"
RUN git clone -b master https://github.com/StratusNetwork/test-util.git && cd test-util && mvn clean install
RUN git clone -b master https://github.com/StratusNetwork/minecraft-api.git && cd minecraft-api && mvn clean install
RUN git clone -b rebase-1.12 https://github.com/StratusNetwork/SportBukkit.git && cd SportBukkit && rake compile
RUN git clone -b master https://github.com/StratusNetwork/BungeeCord.git && cd BungeeCord && mvn clean install
RUN git clone -b sportbukkit https://github.com/StratusNetwork/ProtocolSupport.git && cd ProtocolSupport && gradle build
RUN git clone -b master https://github.com/StratusNetwork/raven-minecraft.git && cd raven-minecraft && mvn clean install
RUN git clone -b master https://github.com/StratusNetwork/sk89q-command-framework.git && cd sk89q-command-framework && mvn clean install
RUN git clone -b master https://github.com/StratusNetwork/Settings.git && cd Settings && mvn clean install
RUN git clone -b master https://github.com/StratusNetwork/BukkitSettings.git && cd BukkitSettings && mvn clean install
RUN git clone -b master https://github.com/StratusNetwork/Channels.git && cd Channels && mvn clean install
#RUN git clone -b master https://github.com/StratusNetwork/commandbook.git && cd commandbook && mvn clean install
RUN git clone -b master https://github.com/StratusNetwork/ProjectAres.git && cd ProjectAres && mvn clean install
WORKDIR ..
