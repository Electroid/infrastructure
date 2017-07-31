FROM ruby:2.1.5
RUN gem install bundle

# Clone the repository
RUN git clone https://github.com/StratusNetwork/OCN.git
WORKDIR OCN

# Build the cached version of the repo
ARG CACHE=a0b44e801f02cbc4b38b494518637aebe986c165
RUN git reset --hard $CACHE
RUN bundle install

# Break the cache and get the latest version of the repository
ARG BRANCH=master
ADD https://${AUTH}api.github.com/repos/StratusNetwork/OCN/git/refs/heads/${BRANCH} ocn.json
RUN git reset --hard origin/$BRANCH && git pull
RUN bundle install

# Website role and port variables
ENV RAILS_ENV=development
ENV WEB_ROLE=octc
ENV WEB_PORT=3000

# Copy mongo config (override existing repository)
COPY mongoid.yml ./config/mongoid.yml

# Default to running rails with role on build
CMD exec rails $WEB_ROLE -b 0.0.0.0

# Create health check to monitor for downtime
HEALTHCHECK --start-period=15s CMD curl -f http://localhost:$WEB_PORT/ || exit 1

# Load ocn data repository (needs to be in this directory)
VOLUME /minecraft/repo/data