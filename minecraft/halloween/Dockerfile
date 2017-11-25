FROM minecraft:bukkit

# Merge halloween configuration to bukkit
COPY . .
RUN rm plugins/PGM/config.yml && mv pgm.yml plugins/PGM/config.yml

# Start the halloween server
CMD exec ./start-bukkit.sh