FROM ruby:2.3-alpine3.7

RUN apk update && \
    apk --no-cache add git curl bash ruby-dev build-base

WORKDIR worker

COPY Gemfile Gemfile
COPY lib lib

RUN bundle install --without test

RUN apk del ruby-dev build-base && \
	rm -rf /var/cache/apk/*

RUN mv lib/worker/* .

ENTRYPOINT ["ruby", "-I", "lib"]
CMD worker.rb
