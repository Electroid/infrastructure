FROM ruby:2.1.5
RUN gem install bundle

# Clone the repository
RUN git clone https://github.com/StratusNetwork/web.git
WORKDIR OCN

# Build the cached version of the repo
ARG CACHE=77f70ff5811c6da31a437118343575d8dc2e57b3
RUN git reset --hard $CACHE
RUN bundle install

# Break the cache and get the latest version of the repository
ARG BRANCH=master
ADD https://${AUTH}api.github.com/repos/StratusNetwork/web/git/refs/heads/${BRANCH} ocn.json
RUN git pull && git reset --hard origin/$BRANCH && git pull
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
