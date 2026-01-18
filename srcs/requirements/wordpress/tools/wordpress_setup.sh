#!/bin/bash
set -e


echo "Starting WordPress setup..."

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
until mariadb -h mariadb -u "$USERNAME_DATABASE" -p"$PASSWORD_DATABASE" -e "SELECT 1" &> /dev/null; do
    echo "MariaDB is not ready, waiting..."
    sleep 2
done
echo "MariaDB is ready!"

cd /var/www/html

# Install WP-CLI
if [ ! -f /usr/local/bin/wp ]; then
    echo "Installing WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Download WordPress if not present
if [ ! -f /var/www/html/wp-settings.php ]; then
    echo "Downloading WordPress..."
    wp core download --path=/var/www/html --allow-root
fi

rm -f /var/www/html/wp-config.php

wp config create --dbname=$NAME_DATABASE --dbuser=$USERNAME_DATABASE --dbpass=$PASSWORD_DATABASE --dbhost=mariadb --allow-root

# Install WordPress if not already installed
if ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --path=/var/www/html \
        --url=$WP_URL  \
        --title="Inception" \
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

# Create Force Login mu-plugin manually
echo "Setting up Force Login..."
mkdir -p /var/www/html/wp-content/mu-plugins
cat > /var/www/html/wp-content/mu-plugins/force-login.php <<'EOFPHP'
<?php
/**
 * Plugin Name: Force Login
 * Description: Require users to log in to view the site
 */
function force_login_redirect() {
    if (!is_user_logged_in() && !wp_doing_ajax() && !defined('WP_CLI')) {
        $current_url = (isset($_SERVER['HTTPS']) ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];
        $login_url = wp_login_url($current_url);
        if (strpos($_SERVER['REQUEST_URI'], 'wp-login.php') === false && strpos($_SERVER['REQUEST_URI'], 'wp-cron.php') === false) {
            wp_redirect($login_url);
            exit;
        }
    }
}
add_action('template_redirect', 'force_login_redirect');
EOFPHP

chown -R www-data:www-data /var/www/html

# Start PHP-FPM in foreground
echo "Starting PHP-FPM..."
exec $@