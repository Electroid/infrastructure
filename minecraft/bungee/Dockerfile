FROM stratusnetwork/minecraft:shared

# Merge Bungee configuration to shared
COPY . .

# Copy BungeeCord jar to server folder
RUN cp /minecraft/build/BungeeCord/bootstrap/target/BungeeCord.jar bungeecord.jar

# Move to plugins folder
WORKDIR plugins

# Copy plugin jars to folder (maybe change to use find)
RUN cp /minecraft/build/ProjectAres/API/ocn/target/api-ocn-1.12-SNAPSHOT.jar api-ocn.jar && \
  cp /minecraft/build/ProjectAres/API/bungee/target/api-bungee-1.12-SNAPSHOT.jar api.jar && \
  cp /minecraft/build/ProjectAres/Commons/bungee/target/commons-bungee-1.12-SNAPSHOT.jar commons.jar

# Start the bungee server
WORKDIR ..
RUN chmod +x bungeecord.jar
ENV SERVER_STAGE=DEVELOPMENT
CMD java -Xmx512m \
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
  -jar bungeecord.jar nogui -stage $SERVER_STAGE