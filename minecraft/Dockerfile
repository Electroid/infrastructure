FROM stratusnetwork/resources:base

# Install software tools
RUN apt-get update && \
  apt-get install -y \
  ca-certificates \
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

# Compile plugins for Bukkit and Bungee
RUN ./clone.sh test-util               "mvn clean install"
RUN ./clone.sh minecraft-api           "mvn clean install"
RUN ./clone.sh SportBukkit             "rake compile"      rebase-1.12
RUN ./clone.sh BungeeCord              "mvn clean install"
RUN ./clone.sh ProtocolSupport         "gradle build"      sportbukkit
RUN ./clone.sh raven-minecraft         "mvn clean install"
RUN ./clone.sh sk89q-command-framework "mvn clean install"
RUN ./clone.sh Settings                "mvn clean install"
RUN ./clone.sh BukkitSettings          "mvn clean install"
RUN ./clone.sh Channels                "mvn clean install"
RUN ./clone.sh ProjectAres             "mvn clean install"

# Start healthcheck with a delay for startup time
HEALTHCHECK --start-period=90s --interval=15s --timeout=10s CMD mcstatus localhost:$SERVER_PORT ping

# Move out of build directory and create minecraft directory
WORKDIR ..
WORKDIR minecraft
