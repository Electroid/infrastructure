FROM stratusnetwork/maven as libraries
ARG AUTH
ADD https://${AUTH}api.github.com/repos/StratusNetwork/test-util/git/refs/heads/master test-util.json
RUN ./clone.sh StratusNetwork test-util master
ADD https://${AUTH}api.github.com/repos/StratusNetwork/minecraft-api/git/refs/heads/master minecraft-api.json
RUN ./clone.sh StratusNetwork minecraft-api master

FROM stratusnetwork/maven as bungee
ARG AUTH
COPY --from=libraries /root/.m2/ /root/.m2/
ADD https://${AUTH}api.github.com/repos/StratusNetwork/BungeeCord/git/refs/heads/master bungeecord.json
RUN ./clone.sh StratusNetwork BungeeCord master

FROM stratusnetwork/maven as sportbukkit
RUN apk update && apk add --no-cache ruby-rake unzip && apk add patch --update
COPY --from=bungee /root/.m2 /root/.m2
RUN git config --global user.email $HOSTNAME@docker.com && \
    git config --global user.name $HOSTNAME
ARG AUTH
ADD https://${AUTH}api.github.com/repos/StratusNetwork/SportBukkit/git/refs/heads/rebase-1.12 sportbukkit.json
RUN ./clone.sh StratusNetwork SportBukkit rebase-1.12 "rake compile"

FROM stratusnetwork/gradle as protocol
COPY --from=sportbukkit /root/.m2 /root/.m2
ARG AUTH
ADD https://${AUTH}api.github.com/repos/StratusNetwork/ProtocolSupport/git/refs/heads/sportbukkit protocol.json
RUN git clone -b sportbukkit https://github.com/StratusNetwork/ProtocolSupport && cd ProtocolSupport && gradle build

FROM stratusnetwork/maven as frameworks
COPY --from=sportbukkit /root/.m2 /root/.m2
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
ADD https://${AUTH}api.github.com/repos/StratusNetwork/ProjectAres/git/refs/heads/master plugins.json
RUN ./clone.sh StratusNetwork ProjectAres master

#FROM stratusnetwork/gradle as worldedit
#COPY --from=sportbukkit /root/.m2 /root/.m2
#ARG AUTH
#ADD https://${AUTH}api.github.com/repos/StratusNetwork/WorldEdit/git/refs/heads/master worldedit.json
#RUN git clone -b master https://github.com/StratusNetwork/WorldEdit && cd WorldEdit && ./gradlew clean setupDecompWorkspace && ./gradlew build

FROM alpine as artifacts
RUN mkdir -p /artifacts/bukkit && mkdir -p /artifacts/bungee 
WORKDIR /root/.m2/repository
COPY --from=plugins /root/.m2 /root/.m2
RUN find tc/oc/bungeecord-bootstrap -name 'bungeecord-bootstrap-*.jar' -exec cp {} /artifacts/bungee/bungeecord.jar \;
RUN find tc/oc/sportbukkit -name 'sportbukkit-*.jar' -exec cp {} /artifacts/bukkit/sportbukkit.jar \;
RUN find tc/oc/raven-bukkit -name 'raven-bukkit-*.jar' -exec cp {} /artifacts/bukkit/raven.jar \;
RUN find tc/oc/raven-bungee -name 'raven-bungee-*.jar' -exec cp {} /artifacts/bungee/raven.jar \;
RUN find tc/oc/api-bukkit -name 'api-bukkit-*.jar' -exec cp {} /artifacts/bukkit/api.jar \;
RUN find tc/oc/api-bungee -name 'api-bungee-*.jar' -exec cp {} /artifacts/bungee/api.jar \;
RUN find tc/oc/api-ocn -name 'api-ocn-*.jar' -exec cp {} /artifacts/bukkit/api-ocn.jar \;
RUN find tc/oc/api-ocn -name 'api-ocn-*.jar' -exec cp {} /artifacts/bungee/api-ocn.jar \;
RUN find tc/oc/commons-bukkit -name 'commons-bukkit-*.jar' -exec cp {} /artifacts/bukkit/commons.jar \;
RUN find tc/oc/commons-bungee -name 'commons-bungee-*.jar' -exec cp {} /artifacts/bungee/commons.jar \;
RUN find tc/oc/Lobby -name 'Lobby-*.jar' -exec cp {} /artifacts/bukkit/lobby.jar \;
RUN find tc/oc/PGM -name 'PGM-*.jar' -exec cp {} /artifacts/bukkit/pgm.jar \;
RUN find com/github/rmsy -name 'Channels-*.jar' -exec cp {} /artifacts/bukkit/channels.jar \;
RUN find me/anxuiz/bukkit-settings -name 'bukkit-settings-*.jar' -exec cp {} /artifacts/bukkit/settings.jar \;
RUN find net/anxuiz/Tourney -name 'Tourney-*.jar' -exec cp {} /artifacts/bukkit/tourney.jar \;
COPY --from=protocol /home/gradle/ProtocolSupport/target/ProtocolSupport.jar /artifacts/bukkit/protocol.jar
#COPY --from=worldedit /home/gradle/WorldEdit/worldedit-bukkit/build/libs/worldedit-bukkit-*-dist.jar /artifacts/bukkit/worldedit.jar

FROM anapsix/alpine-java:8_server-jre as server
RUN apk update && apk add --no-cache py-pip gettext
RUN pip install mcstatus
WORKDIR minecraft
COPY --from=artifacts /artifacts/bungee /minecraft/bungee/plugins
RUN mv bungee/plugins/bungeecord.jar bungee/server.jar
COPY --from=artifacts /artifacts/bukkit /minecraft/bukkit/plugins
RUN mv bukkit/plugins/sportbukkit.jar bukkit/server.jar
