<?php

/**
 * The base configuration for WordPress
 */

// ** Database settings ** //
/** The name of the database for WordPress */
define( 'DB_NAME', getenv('NAME_DATABASE') );

/** Database username */
define( 'DB_USER', getenv('USERNAME_DATABASE') );

/** Database password */
define( 'DB_PASSWORD', getenv('PASSWORD_DATABASE') );

/** Database hostname */
define( 'DB_HOST', 'mariadb' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**
 * Authentication unique keys and salts.
 */
define( 'AUTH_KEY',         getenv('AUTH_KEY') ?: 'put-unique-phrase-here' );
define( 'SECURE_AUTH_KEY',  getenv('SECURE_AUTH_KEY') ?: 'put-unique-phrase-here' );
define( 'LOGGED_IN_KEY',    getenv('LOGGED_IN_KEY') ?: 'put-unique-phrase-here' );
define( 'NONCE_KEY',        getenv('NONCE_KEY') ?: 'put-unique-phrase-here' );
define( 'AUTH_SALT',        getenv('AUTH_SALT') ?: 'put-unique-phrase-here' );
define( 'SECURE_AUTH_SALT', getenv('SECURE_AUTH_SALT') ?: 'put-unique-phrase-here' );
define( 'LOGGED_IN_SALT',   getenv('LOGGED_IN_SALT') ?: 'put-unique-phrase-here' );
define( 'NONCE_SALT',       getenv('NONCE_SALT') ?: 'put-unique-phrase-here' );

/**
 * WordPress database table prefix.
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 */
define( 'WP_DEBUG', false );

// WordPress Site URLs
define( 'WP_HOME', getenv('WP_URL') );
define( 'WP_SITEURL', getenv('WP_URL') );

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';