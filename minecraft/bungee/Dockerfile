FROM minecraft:bungee-shared

# Merge Bungee configuration to shared
COPY . .

# Copy bungee artifacts to the server folder
RUN cp -R /minecraft/bungee/* .

# Bungee specific variables
ENV SERVER_ROLE=BUNGEE
ENV SERVER_PROXY=false
ENV SERVER_ONLINE=true
ENV SERVER_RESTART=12h
ENV SERVER_EMPTY_TIMEOUT=3h
ENV SERVER_KICK_LIMIT=2
ENV SERVER_LOBBY_IP=lobby.stratus.network
ENV SERVER_LOBBY_PORT=1337

# Start the bungee server
CMD exec ./start.sh