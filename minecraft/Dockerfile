FROM stratusnetwork/maven as libraries
ARG AUTH
ADD https://${AUTH}api.github.com/repos/StratusNetwork/test-util/git/refs/heads/master test-util.json
RUN ./clone.sh StratusNetwork test-util master
ADD https://${AUTH}api.github.com/repos/StratusNetwork/minecraft-api/git/refs/heads/master minecraft-api.json
RUN ./clone.sh StratusNetwork minecraft-api master

FROM stratusnetwork/maven as bungee
COPY --from=libraries /root/.m2 /root/.m2
ARG AUTH
ARG BRANCH_BASE=master
ADD https://${AUTH}api.github.com/repos/StratusNetwork/BungeeCord/git/refs/heads/$BRANCH_BASE bungeecord.json
RUN ./clone.sh StratusNetwork BungeeCord $BRANCH_BASE

FROM stratusnetwork/maven as bukkit
RUN apk update && apk add --no-cache ruby-rake unzip && apk add patch --update
RUN git config --global user.email $HOSTNAME@docker.com && \
    git config --global user.name $HOSTNAME
COPY --from=bungee /root/.m2 /root/.m2
ARG AUTH
ARG BRANCH_BASE=master
ADD https://${AUTH}api.github.com/repos/StratusNetwork/SportBukkit/git/refs/heads/$BRANCH_BASE sportbukkit.json
RUN ./clone.sh StratusNetwork SportBukkit $BRANCH_BASE "rake compile"

FROM stratusnetwork/gradle as protocol
COPY --from=bukkit /root/.m2 /root/.m2
ARG AUTH
ADD https://${AUTH}api.github.com/repos/StratusNetwork/ProtocolSupport/git/refs/heads/master protocol.json
RUN git clone -b master https://github.com/StratusNetwork/ProtocolSupport && cd ProtocolSupport && gradle build

FROM stratusnetwork/maven as frameworks
COPY --from=bukkit /root/.m2 /root/.m2
ARG AUTH
ADD https://${AUTH}api.github.com/repos/StratusNetwork/raven-minecraft/git/refs/heads/master raven-minecraft.json
RUN ./clone.sh StratusNetwork raven-minecraft master
ADD https://${AUTH}api.github.com/repos/StratusNetwork/sk89q-command-framework/git/refs/heads/master sk89q-command-framework.json
RUN ./clone.sh StratusNetwork sk89q-command-framework master

FROM stratusnetwork/maven as dependencies
COPY --from=frameworks /root/.m2 /root/.m2
ARG AUTH
ADD https://${AUTH}api.github.com/repos/StratusNetwork/Settings/git/refs/heads/master settings.json
RUN ./clone.sh StratusNetwork Settings master
ADD https://${AUTH}api.github.com/repos/StratusNetwork/BukkitSettings/git/refs/heads/master bukkitsettings.json
RUN ./clone.sh StratusNetwork BukkitSettings master
ADD https://${AUTH}api.github.com/repos/StratusNetwork/Channels/git/refs/heads/master channels.json
RUN ./clone.sh StratusNetwork Channels master
# ADD https://${AUTH}api.github.com/repos/StratusNetwork/ChatModerator/git/refs/heads/master chatmoderator.json
# RUN ./clone.sh StratusNetwork ChatModerator master

FROM stratusnetwork/maven as plugins
COPY --from=dependencies /root/.m2 /root/.m2
ARG AUTH
ARG BRANCH_PLUGINS=master
ADD https://${AUTH}api.github.com/repos/StratusNetwork/ProjectAres/git/refs/heads/$BRANCH_PLUGINS plugins.json
RUN ./clone.sh StratusNetwork ProjectAres $BRANCH_PLUGINS

# FROM stratusnetwork/gradle as worldedit
# COPY --from=bukkit /root/.m2 /root/.m2
# ARG AUTH
# ADD https://${AUTH}api.github.com/repos/sk89q/WorldEdit/git/refs/heads/master worldedit.json
# RUN git clone -b master https://github.com/sk89q/WorldEdit && cd WorldEdit && ./gradlew clean setupDecompWorkspace && ./gradlew build

FROM alpine as artifacts
RUN mkdir -p /artifacts/bukkit && mkdir -p /artifacts/bungee 
WORKDIR /root/.m2/repository
COPY --from=plugins /root/.m2 /root/.m2
# COPY --from=minecraft /Waterfall/Waterfall-Proxy/bootstrap/target/BungeeCord.jar /artifacts/bungee/bungeecord.jar
RUN find tc/oc/bungeecord-bootstrap -name 'bungeecord-bootstrap-*.jar' -exec mv {} /artifacts/bungee/bungeecord.jar \;
RUN find tc/oc/sportbukkit -name 'sportbukkit-*.jar' -exec mv {} /artifacts/bukkit/sportbukkit.jar \;
RUN find tc/oc/raven-bukkit -name 'raven-bukkit-*.jar' -exec mv {} /artifacts/bukkit/raven.jar \;
RUN find tc/oc/raven-bungee -name 'raven-bungee-*.jar' -exec mv {} /artifacts/bungee/raven.jar \;
RUN find tc/oc/api-bukkit -name 'api-bukkit-*.jar' -exec mv {} /artifacts/bukkit/api.jar \;
RUN find tc/oc/api-bungee -name 'api-bungee-*.jar' -exec mv {} /artifacts/bungee/api.jar \;
RUN find tc/oc/api-ocn -name 'api-ocn-*.jar' -exec cp {} /artifacts/bukkit/api-ocn.jar \;
RUN find tc/oc/api-ocn -name 'api-ocn-*.jar' -exec mv {} /artifacts/bungee/api-ocn.jar \;
RUN find tc/oc/commons-bukkit -name 'commons-bukkit-*.jar' -exec mv {} /artifacts/bukkit/commons.jar \;
RUN find tc/oc/commons-bungee -name 'commons-bungee-*.jar' -exec mv {} /artifacts/bungee/commons.jar \;
RUN find tc/oc/Lobby -name 'Lobby-*.jar' -exec mv {} /artifacts/bukkit/lobby.jar \;
RUN find tc/oc/PGM -name 'PGM-*.jar' -exec mv {} /artifacts/bukkit/pgm.jar \;
RUN find com/github/rmsy -name 'Channels-*.jar' -exec mv {} /artifacts/bukkit/channels.jar \;
RUN find me/anxuiz/bukkit-settings -name 'bukkit-settings-*.jar' -exec mv {} /artifacts/bukkit/settings.jar \;
RUN find net/anxuiz/Tourney -name 'Tourney-*.jar' -exec mv {} /artifacts/bukkit/tourney.jar \;
COPY --from=protocol /home/gradle/ProtocolSupport/target/ProtocolSupport.jar /artifacts/bukkit/protocol.jar
# COPY --from=worldedit /home/gradle/WorldEdit/worldedit-bukkit/build/libs/worldedit-bukkit-*-dist.jar /artifacts/bukkit/worldedit.jar

FROM openjdk:8u121 as server
RUN apt-get update
RUN apt-get install -y curl gettext jq python-pip
RUN pip install mcstatus
WORKDIR minecraft
COPY --from=artifacts /artifacts/bungee /minecraft/bungee/plugins
RUN mv bungee/plugins/bungeecord.jar bungee/server.jar
COPY --from=artifacts /artifacts/bukkit /minecraft/bukkit/plugins
RUN mv bukkit/plugins/sportbukkit.jar bukkit/server.jar
