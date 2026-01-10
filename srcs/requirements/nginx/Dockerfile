FROM debian:stable

RUN apt-get update  && apt-get install -y nginx openssl \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/default.conf /etc/nginx/default.conf

CMD [ "nginx", "-g", "daemon off;" ]