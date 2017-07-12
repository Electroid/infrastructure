FROM stratusnetwork/minecraft:shared

# Merge Bukkit configuration to shared
COPY . .
RUN cd plugins-bukkit && cp -R * ../plugins && cd .. && rm -rf plugins-bukkit

# Copy SportBukkit jar to server folder
RUN cp /minecraft/build/SportBukkit/build/CraftBukkit/target/sportbukkit-1.12-pre6-SNAPSHOT.jar sportbukkit.jar

# Move to plugins folder
WORKDIR plugins

# Copy plugin jars to folder (maybe change to use find)
RUN cp /minecraft/build/ProtocolSupport/target/ProtocolSupport.jar protocol.jar && \
  cp /minecraft/build/raven-minecraft/raven-bukkit/target/raven-bukkit-1.11-SNAPSHOT.jar raven.jar && \
  cp /minecraft/build/BukkitSettings/target/bukkit-settings-1.9-SNAPSHOT.jar settings.jar && \
  cp /minecraft/build/Channels/target/Channels-1.9-SNAPSHOT.jar channels.jar && \
  #cp /minecraft/build/commandbook/target/commandbook.jar commandbook.jar && \
  cp /minecraft/build/ProjectAres/API/ocn/target/api-ocn-1.12-SNAPSHOT.jar api-ocn.jar && \
  cp /minecraft/build/ProjectAres/API/bukkit/target/api-bukkit-1.12-SNAPSHOT.jar api.jar && \
  cp /minecraft/build/ProjectAres/Commons/bukkit/target/commons-bukkit-1.12-SNAPSHOT.jar commons.jar && \
  cp /minecraft/build/ProjectAres/PGM/target/PGM-1.12-SNAPSHOT.jar pgm.jar

# Start the bukkit server
WORKDIR ..
RUN chmod +x sportbukkit.jar
ENV SERVER_STAGE=DEVELOPMENT
CMD java -Xmx1G \
  -XX:+UseLargePages \
  -XX:+AggressiveOpts \
  -XX:+UseFastAccessorMethods \
  -XX:+OptimizeStringConcat \
  -XX:+UseBiasedLocking -Xincgc \
  -XX:MaxGCPauseMillis=50 \
  -XX:SoftRefLRUPolicyMSPerMB=10000 \
  -XX:+CMSParallelRemarkEnabled \
  -XX:ParallelGCThreads=5 \
  -Djava.net.preferIPv4Stack=true \
  -jar sportbukkit.jar nogui -stage $SERVER_STAGE