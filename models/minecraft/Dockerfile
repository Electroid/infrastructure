FROM openjdk:10-jre-slim

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl git build-essential ruby ruby-dev rubygems && \
    echo "gem: --no-rdoc --no-ri" > ~/.gemrc && \
    gem install bundler

WORKDIR minecraft

ADD https://${AUTH}api.github.com/repos/StratusNetwork/Data/git/refs/heads/${BRANCH} data.json
RUN git clone -b master --depth 1 https://github.com/StratusNetwork/Data.git data

WORKDIR repo
RUN git clone -b master --depth 1 https://gitlab.com/stratus/config.git Config

WORKDIR /minecraft/server

COPY lib lib
COPY Gemfile Gemfile
COPY models/minecraft .
RUN rm build.yml

RUN bundle install --without test worker

RUN apt-get remove -y build-essential ruby-dev rubygems && \
    apt-get -y autoremove

ARG PROJECT_ID=stratus-197318
ARG BRANCH=master
ENV URL=https://storage.googleapis.com/artifacts.$PROJECT_ID.appspot.com/artifacts/$BRANCH/.m2
ENV MASTER_URL=https://storage.googleapis.com/artifacts.$PROJECT_ID.appspot.com/artifacts/master/.m2
ARG VERSION=1.12.2-SNAPSHOT
ENV VERSION=$VERSION

ENV STAGE=DEVELOPMENT
ENV API=http://api
ENV RABBIT=rabbit

ENV ESC=$

ENV JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XshowSettings:vm -XX:MaxRAMFraction=1 -XX:+AggressiveOpts -XX:+AlwaysPreTouch -XX:LargePageSizeInBytes=2M -XX:+UseLargePages -XX:+UseLargePagesInMetaspace -XX:+AggressiveHeap -XX:+OptimizeStringConcat -XX:+UseStringDeduplication -XX:+UseCompressedOops -XX:TargetSurvivorRatio=90 -XX:InitiatingHeapOccupancyPercent=10 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=2 -XX:+DisableExplicitGC -XX:+UseAdaptiveGCBoundary -Xnoclassgc"

ENV JAVA_EXPERIMENTAL_OPTS="-XX:+UseG1GC -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=50 -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:InitiatingHeapOccupancyPercent=10"

CMD cd ../data && git pull && cd ../repo/Config && git pull && \
    cd ../../server && ruby run.rb "load!" && \
                    exec java -jar server.jar -stage $STAGE
