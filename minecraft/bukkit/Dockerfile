FROM stratusnetwork/minecraft-shared

# Merge Bukkit configuration to shared
COPY . .
RUN cd plugins-bukkit && cp -R * ../plugins && cd .. && rm -rf plugins-bukkit
RUN chmod +x start-bukkit.sh

# Copy bukkit artifacts to the server folder
RUN cp -R /minecraft/bukkit/* .

# Bukkit specific variables
ENV SERVER_ROLE=PGM
ENV SERVER_RESTART=24h
ENV SERVER_KICK_LIMIT=1000
ENV SERVER_ONLINE=false
ENV SERVER_BUNGEECORD=true
ENV SERVER_FLAIRS_OVERHEAD=false
ENV SERVER_FLAIRS_LIMIT=-1
ENV JAVA_OPTS='-Xms500m -Xmx2000m'

# Start the bukkit server
CMD exec ./start-bukkit.sh