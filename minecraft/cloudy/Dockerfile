FROM minecraft:bukkit

# Change directory to allow persistent storage
RUN mv /minecraft/server /minecraft/server-new
WORKDIR /minecraft/server-new

# Merge cloudy configuration to bukkit
COPY . .

# Start the cloudy server
CMD exec ./start-cloudy.sh