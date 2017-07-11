FROM stratusnetwork/minecraft:shared

# Merge Bukkit configuration to shared
COPY . .
RUN cd plugins-bukkit && cp -R * plugins && cd .. && rm -rf plugins-bukkit

# Move SportBukkit jar to server folder
RUN mv /minecraft/build/SportBukkit/build/CraftBukkit/target/sportbukkit-1.12-pre6-SNAPSHOT.jar sportbukkit.jar

# Move to plugins folder
WORKDIR plugins

# Move plugin jars to folder (maybe change to use find)
RUN mv /minecraft/build/ProtocolSupport/target/ProtocolSupport.jar protocol.jar && \
  mv /minecraft/build/raven-minecraft/raven-bukkit/target/raven-bukkit-1.9-SNAPSHOT.jar raven.jar && \
  mv /minecraft/build/BukkitSettings/target/bukkit-settings-1.9-SNAPSHOT.jar settings.jar && \
  mv /minecraft/build/Channels/target/Channels-1.9-SNAPSHOT.jar channels.jar && \
  mv /minecraft/build/commandbook/target/commandbook.jar commandbook.jar && \
  mv /minecraft/build/ProjectAres/API/ocn/target/api-ocn-1.12-SNAPSHOT.jar api-ocn.jar && \
  mv /minecraft/build/ProjectAres/API/bukkit/target/api-bukkit-1.12-SNAPSHOT.jar api.jar && \
  mv /minecraft/build/ProjectAres/Commons/bukkit/target/commons-bukkit-1.12-SNAPSHOT.jar commons.jar && \
  mv /minecraft/build/ProjectAres/PGM/target/PGM-1.12-SNAPSHOT.jar pgm.jar

# Start the minecraft server
echo "Start Bukkit!"