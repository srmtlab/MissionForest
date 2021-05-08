FROM ruby:2.6.3-alpine3.10

LABEL maintainer="Akira Kamiya <a.kamiya.208@srmtlab.org>"

ENV APP_DIR /app
ENV DOCKERIZE_VERSION v0.6.1

WORKDIR ${APP_DIR}

RUN apk update \
    # Dependencies are installed here.
    && apk add --virtual .build-deps nodejs build-base mariadb-dev tzdata git shared-mime-info

# see : https://docs.docker.com/compose/startup-order/
# install dockerize : https://github.com/jwilder/dockerize
RUN apk add --no-cache openssl
RUN wget https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    && rm dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz

# Requirements are installed here.
ADD ./Gemfile ${APP_DIR}/Gemfile
ADD ./Gemfile.lock ${APP_DIR}/Gemfile.lock
RUN bundle install

COPY ./compose/production/rails/entrypoint /entrypoint
RUN sed -i 's/\r$//g' /entrypoint
RUN chmod +x /entrypoint

COPY ./compose/development/rails/start /start
RUN sed -i 's/\r$//g' /start
RUN chmod +x /start

ENTRYPOINT ["/entrypoint"]