FROM minecraft:bungee-shared

# Merge Bungee configuration to shared
COPY . .

# Bungee specific variables
ENV SERVER_ROLE=BUNGEE
ENV SERVER_PROXY=false
ENV SERVER_ONLINE=true
ENV SERVER_RESTART=12h
ENV SERVER_EMPTY_TIMEOUT=3h
ENV SERVER_KICK_LIMIT=3
ENV SERVER_UPTIME_LIMIT=24h
ENV SERVER_DEFAULT_ROUTE=lobby
ENV SERVER_REQUEST=false

# Start the bungee server
CMD exec ./start.sh