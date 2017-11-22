FROM stratusnetwork/minecraft:shared

# Merge Bukkit configuration to shared
COPY . .
RUN cd plugins-bukkit && cp -R * ../plugins && cd .. && rm -rf plugins-bukkit
RUN chmod +x start-bukkit.sh

# Copy bukkit artifacts to the server folder
RUN cp -R /minecraft/bukkit/* .

# Bukkit specific variables
ENV SERVER_ROLE=PGM
ENV SERVER_RESTART=24h
ENV SERVER_KICK_LIMIT=256
ENV SERVER_ONLINE=false
ENV SERVER_BUNGEECORD=true
ENV SERVER_FLAIRS_OVERHEAD=false
ENV SERVER_FLAIRS_LIMIT=-1
ENV SERVER_STATS=true
ENV SERVER_COMMAND_BLOCK=false
ENV SERVER_TIMEOUT=0
ENV SERVER_OP=4
ENV SERVER_SIZE=256

# Start the bukkit server
CMD exec ./start-bukkit.sh