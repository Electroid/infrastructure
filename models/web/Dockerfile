FROM ruby:2.3.8
RUN gem install bundle

# Clone the repository
RUN git clone https://github.com/StratusNetwork/web.git
WORKDIR web

RUN gem install therubyracer -v '0.12.1'
RUN gem install libv8 -v '3.16.14.5'  -- --with-system-v8

# Build the cached version of the repo
ARG CACHE=ccd5ccbcdd7dd84a654abf9d3bfde0b8e638855d
RUN git reset --hard $CACHE
RUN bundle install

# Break the cache and get the latest version of the repository
ARG BRANCH=master
ADD https://${AUTH}api.github.com/repos/StratusNetwork/web/git/refs/heads/${BRANCH} web.json

RUN git reset --hard && git pull && git reset --hard origin/$BRANCH && git pull
RUN bundle install

# Website role and port variables
ENV RAILS_ENV=production
ENV OCN_BOX=production
ENV WEB_ROLE=octc
ENV WEB_PORT=3000

# Copy config files (override existing repository)
COPY mongoid.yml ./config/mongoid.yml

# Default to running rails with role on build
CMD exec rails $WEB_ROLE -b 0.0.0.0 -p $WEB_PORT

# Load ocn data repository (needs to be in this directory)
VOLUME /minecraft/repo/data
