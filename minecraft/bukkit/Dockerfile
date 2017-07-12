FROM stratusnetwork/minecraft:shared

# Merge Bukkit configuration to shared
COPY . .
RUN cd plugins-bukkit && cp -R * ../plugins && cd .. && rm -rf plugins-bukkit
RUN chmod +x bukkit-start.sh

# Copy SportBukkit jar to server folder
RUN cp /minecraft/build/SportBukkit/build/CraftBukkit/target/sportbukkit-1.12-pre6-SNAPSHOT.jar server.jar && chmod +x server.jar

# Move to plugins folder
WORKDIR plugins

# Copy plugin jars to folder (maybe change to use find)
RUN cp /minecraft/build/ProtocolSupport/target/ProtocolSupport.jar protocol.jar && \
  cp /minecraft/build/raven-minecraft/raven-bukkit/target/raven-bukkit-1.11-SNAPSHOT.jar raven.jar && \
  cp /minecraft/build/BukkitSettings/target/bukkit-settings-1.9-SNAPSHOT.jar settings.jar && \
  cp /minecraft/build/Channels/target/Channels-1.9-SNAPSHOT.jar channels.jar && \
  cp /minecraft/build/ProjectAres/API/ocn/target/api-ocn-1.12-SNAPSHOT.jar api-ocn.jar && \
  cp /minecraft/build/ProjectAres/API/bukkit/target/api-bukkit-1.12-SNAPSHOT.jar api.jar && \
  cp /minecraft/build/ProjectAres/Commons/bukkit/target/commons-bukkit-1.12-SNAPSHOT.jar commons.jar && \
  cp /minecraft/build/ProjectAres/PGM/target/PGM-1.12-SNAPSHOT.jar pgm.jar && \
  cp /minecraft/build/ProjectAres/Lobby/target/Lobby-1.12-SNAPSHOT.jar lobby.jar
WORKDIR ..

# Bukkit specific variables
ENV SERVER_ROLE=PGM
ENV JAVA_OPTS='-Xms500m -Xmx2000m'

# Start the bukkit server
CMD ./bukkit-start.sh