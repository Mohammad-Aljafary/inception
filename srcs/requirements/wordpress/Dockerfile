FROM debian:stable

RUN  apt-get update \
    &&  apt-get install -y apache2 mariadb-server mariadb-client php libapache2-mod-php php-mysql php-imagick php-curl php-json php-mbstring php-xml php-zip ghostscript \
    && rm -rf /var/lib/apt/lists/*


RUN apt-get install -y curl

COPY ./tools/ /tmp/tools/

RUN chmod +x /tmp/tools/wordpress_setup.sh 

ENTRYPOINT [ "/tmp/tools/wordpress_setup.sh" ]