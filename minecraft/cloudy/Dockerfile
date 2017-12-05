FROM minecraft:bukkit

# Change directory to allow persistent storage
RUN mv /minecraft/server /minecraft/server-new
WORKDIR /minecraft/server-new

# Merge cloudy configuration to bukkit
COPY . .
# RUN cd plugins-cloudy && cp -R * ../plugins && cd .. && rm -rf plugins-cloudy

# Start the cloudy server
CMD exec ./start-cloudy.sh