FROM debian:12

RUN  apt-get update  && apt-get install -y mariadb-server mariadb-client systemctl \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 3306

COPY  ./conf/my.cnf /etc/mysql/my.cnf
COPY ./tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["mysqld_safe", "--user=mysql", "--datadir=/var/lib/mysql"]
