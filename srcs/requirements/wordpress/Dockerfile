FROM debian:12

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php-fpm \
    php-mysql  \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-intl \
    php-zip \
    wget \
    curl \
    mariadb-client \
    systemctl \
    && rm -rf /var/lib/apt/lists/*

# Create directory
RUN mkdir -p /var/www/html

# Configure PHP-FPM to listen on port 9000
RUN sed -i 's|listen = /run/php/php.*-fpm.sock|listen = 9000|' /etc/php/*/fpm/pool.d/www.conf


COPY tools/wordpress_setup.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]