ARG RUBY_VERSION=ruby:2.6.6-alpine3.13

FROM ${RUBY_VERSION} AS GEMS

RUN apk add --update --no-cache \
    build-base \
    postgresql-dev

COPY . /app/

WORKDIR /app

RUN bundle install

FROM ${RUBY_VERSION}

RUN apk add --update --no-cache \
    build-base \
    postgresql-client

COPY . /app/

WORKDIR /app

COPY --from=GEMS /usr/local/bundle/ /usr/local/bundle/
