FROM ruby:2.6.3-alpine3.10

LABEL maintainer="Akira Kamiya <a.kamiya.208@srmtlab.org>"

ENV APP_DIR /opt/MissionForest

WORKDIR ${APP_DIR}
RUN apk update \
    && apk add nodejs build-base mariadb-dev tzdata

ADD ./Gemfile ${APP_DIR}/Gemfile
ADD ./Gemfile.lock ${APP_DIR}/Gemfile.lock
RUN bundle install
RUN gem install foreman