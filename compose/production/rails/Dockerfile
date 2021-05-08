FROM ruby:2.6.3-alpine3.10

LABEL maintainer="Akira Kamiya <a.kamiya.208@srmtlab.org>"

ENV APP_DIR /app
ENV DOCKERIZE_VERSION v0.6.1
ENV APP_USER missionforest

WORKDIR ${APP_DIR}

RUN apk update \
  # Dependencies are installed here.
  && apk add nodejs build-base mariadb-dev tzdata git shared-mime-info

# see : https://docs.docker.com/compose/startup-order/
# install dockerize : https://github.com/jwilder/dockerize
RUN apk add --no-cache openssl
RUN wget https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
  && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
  && rm dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz

RUN addgroup -S ${APP_USER} \
  && adduser -S -G ${APP_USER} ${APP_USER}

# Requirements are installed here.
COPY ./Gemfile ${APP_DIR}/Gemfile
COPY ./Gemfile.lock ${APP_DIR}/Gemfile.lock
RUN bundle install --without test development

COPY ./compose/production/rails/entrypoint /entrypoint
RUN sed -i 's/\r$//g' /entrypoint
RUN chmod +x /entrypoint

COPY ./compose/production/rails/start /start
RUN sed -i 's/\r$//g' /start
RUN chmod +x /start

COPY . ${APP_DIR}

RUN mkdir public/assets public/uploads
RUN chown -R ${APP_USER} ${APP_DIR}

USER ${APP_USER}

ENTRYPOINT ["/entrypoint"]