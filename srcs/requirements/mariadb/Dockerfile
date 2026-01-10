FROM debian:stable

RUN  apt-get update  && apt-get install -y mariadb-server mariadb-client \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 3306

COPY  ./conf/my.cnf /etc/mysql/my.cnf
COPY ./tools/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
