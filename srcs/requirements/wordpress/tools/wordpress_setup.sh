#!/bin/bash
set -e

systemctl disable apache2
systemctl disable httpd

echo "Starting WordPress setup..."

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
until mariadb -h mariadb -u "$USERNAME_DATABASE" -p"$PASSWORD_DATABASE" -e "SELECT 1" &> /dev/null; do
    echo "MariaDB is not ready, waiting..."
    sleep 2
done
echo "MariaDB is ready!"

cd /var/www/html

# Download WordPress if not present
if [ ! -f /var/www/html/wp-settings.php ]; then
    echo "Downloading WordPress..."
    curl -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
fi

# Create wp-config.php with actual values
cat > /var/www/html/wp-config.php <<EOF
<?php
define( 'DB_NAME', '${NAME_DATABASE}' );
define( 'DB_USER', '${USERNAME_DATABASE}' );
define( 'DB_PASSWORD', '${PASSWORD_DATABASE}' );
define( 'DB_HOST', 'mariadb' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define( 'AUTH_KEY',         'unique-phrase-1' );
define( 'SECURE_AUTH_KEY',  'unique-phrase-2' );
define( 'LOGGED_IN_KEY',    'unique-phrase-3' );
define( 'NONCE_KEY',        'unique-phrase-4' );
define( 'AUTH_SALT',        'unique-phrase-5' );
define( 'SECURE_AUTH_SALT', 'unique-phrase-6' );
define( 'LOGGED_IN_SALT',   'unique-phrase-7' );
define( 'NONCE_SALT',       'unique-phrase-8' );

\$table_prefix = 'wp_';

define( 'WP_DEBUG', true );
define( 'WP_HOME', '${WP_URL}' );
define( 'WP_SITEURL', '${WP_URL}' );

/* Force login for all pages */
define( 'FORCE_LOGIN', true );

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF

chown -R www-data:www-data /var/www/html

# Install WP-CLI
if [ ! -f /usr/local/bin/wp ]; then
    echo "Installing WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Install WordPress if not already installed
if ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --path=/var/www/html \
        --url="https://malja-fa.42.fr" \
        --title="My Site" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
    echo "WordPress installed!"
fi

# Create user if not exists (runs every time)
if ! wp user get "$WP_USER" --allow-root --path=/var/www/html &>/dev/null; then
    echo "Creating a user..."
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author --allow-root \
        --path=/var/www/html
    echo "User created!"
else
    echo "User $WP_USER already exists."
fi

mkdir -p /var/www/html/wp-content/mu-plugins
cat > /var/www/html/wp-content/mu-plugins/force-login.php <<'EOFPHP'
<?php
function force_login() {
    if (!is_user_logged_in() && !strpos($_SERVER['REQUEST_URI'], 'wp-login.php')) {
        auth_redirect();
    }
}
add_action('template_redirect', 'force_login');
EOFPHP

chown www-data:www-data /var/www/html/wp-content/mu-plugins/force-login.php



# Start PHP-FPM in foreground
echo "Starting PHP-FPM..."
exec $@