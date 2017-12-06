ARG BASE
FROM minecraft:$BASE-base

# Copy shared configurations
COPY . .

# Give run access to the start script
RUN chmod +x start.sh

# Shared variables
ENV SERVER_STAGE=PRODUCTION
ENV SERVER_BOX=production
ENV SERVER_IP=0.0.0.0
ENV SERVER_RABBIT_IP=rabbit
ENV SERVER_API_IP=api
ENV SERVER_PORT=25565
ENV SERVER_PUBLISH=true
ENV SERVER_SIGNAL=0
ENV SERVER_REPORTS="['pgm', 'lobby']"
ENV SERVER_CROSS=true
ENV SENTRY_ENABLED=true

# Required variables for each container
ENV SERVER_ID=null
ENV SENTRY_DSN_PLUGINS=null
ENV SERVER_LOCAL=false

# Escape variable to avoid being substituted
ENV ESCAPE=$

# Generic and special optimizing java arguments
ENV JAVA_OPTS="-Xms2G -Xmx2G -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=1 -XX:+AggressiveOpts -XX:+AlwaysPreTouch -XX:LargePageSizeInBytes=2M -XX:+UseLargePages -XX:+UseLargePagesInMetaspace -XX:+AggressiveHeap -XX:+OptimizeStringConcat -XX:+UseStringDeduplication -XX:+UseCompressedOops -XX:TargetSurvivorRatio=90 -XX:InitiatingHeapOccupancyPercent=10 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=2 -XX:+DisableExplicitGC -XX:+UseAdaptiveGCBoundary -Xnoclassgc"

# Potentially cause lag, must investigate later 
ENV JAVA_EXPERIMENTAL_OPTS="-XX:+UseG1GC -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=50 -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:InitiatingHeapOccupancyPercent=10"
