FROM stratusnetwork/minecraft:shared

# Merge Bungee configuration to shared
COPY . .

# Copy BungeeCord jar to server folder
RUN cp /build/BungeeCord/bootstrap/target/BungeeCord.jar server.jar && chmod +x server.jar

# Move to plugins folder
WORKDIR plugins

# Copy plugin jars to folder (maybe change to use find)
RUN cp /build/ProjectAres/API/ocn/target/api-ocn-1.12-SNAPSHOT.jar api-ocn.jar && \
  cp /build/ProjectAres/API/bungee/target/api-bungee-1.12-SNAPSHOT.jar api.jar && \
  cp /build/ProjectAres/Commons/bungee/target/commons-bungee-1.12-SNAPSHOT.jar commons.jar
WORKDIR ..

# Bungee specific variables
ENV SERVER_ROLE=BUNGEE
ENV JAVA_OPTS='-Xms100m -Xmx500m'

# Start the bungee server
CMD ./start.sh