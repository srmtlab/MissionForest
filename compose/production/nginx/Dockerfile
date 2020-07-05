FROM nginx:1.19.0-alpine

LABEL maintainer="Akira Kamiya <a.kamiya.208@srmtlab.org>"

RUN rm /etc/nginx/conf.d/default.conf
COPY ./compose/production/nginx/nginx.conf /etc/nginx/conf.d