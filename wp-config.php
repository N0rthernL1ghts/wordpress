<?php
/**
 * The base configuration for WordPress
 * Adapted for docker environment
 * @author Aleksandar Puharic <xzero@elite7hackers.net>
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

/** Not needed behind the nginx-proxy */
define('FORCE_SSL_ADMIN', false);
define('FORCE_SSL_LOGIN', false);

/** Disable cron (will be run by system crond) */
define('DISABLE_WP_CRON', true);

/** Makes it easier to control in docker environment */
define('WP_CONTENT_DIR', $_ENV['WORDPRESS_CONTENT_DIR'] ?? (__DIR__ . '/wp-content'));

/**
 * Redis Cache
 */
define('WP_REDIS_HOST', $_ENV['WORDPRESS_REDIS_HOST'] ?? null);
define('WP_CACHE', (bool)($_ENV['WORDPRESS_CACHE'] ?? false));
define('WP_CACHE_KEY_SALT', $_ENV['WORDPRESS_CACHE_KEY_SALT'] ?? null);

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME',     $_ENV['WORDPRESS_DB_NAME'] ?? 'wordpress');

/** MySQL database username */
define('DB_USER',     $_ENV['WORDPRESS_DB_USER'] ?? 'wordpress');

/** MySQL database password */
define('DB_PASSWORD', $_ENV['WORDPRESS_DB_PASSWORD'] ?? '');

/** MySQL hostname */
define('DB_HOST',     $_ENV['WORDPRESS_DB_HOST'] ?? 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET',  $_ENV['WORDPRESS_DB_CHARSET'] ?? 'utf8mb4');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE',  $_ENV['WORDPRESS_DB_COLLATION'] ?? '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         $_ENV['WORDPRESS_AUTH_KEY'] ?? '');
define('SECURE_AUTH_KEY',  $_ENV['WORDPRESS_SECURE_AUTH_KEY'] ?? '');
define('LOGGED_IN_KEY',    $_ENV['WORDPRESS_LOGGED_IN_KEY'] ?? '');
define('NONCE_KEY',        $_ENV['WORDPRESS_NONCE_KEY'] ?? '');
define('AUTH_SALT',        $_ENV['WORDPRESS_AUTH_SALT'] ?? '');
define('SECURE_AUTH_SALT', $_ENV['WORDPRESS_SECURE_AUTH_SALT'] ?? '');
define('LOGGED_IN_SALT',   $_ENV['WORDPRESS_LOGGED_IN_SALT'] ?? '');
define('NONCE_SALT',       $_ENV['WORDPRESS_NONCE_SALT'] ?? '');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = $_ENV['WORDPRESS_TABLE_PREFIX'] ?? 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', (bool)($_ENV['WORDPRESS_DEBUG'] ?? false));

/**
 * Other settings
 */
define('FS_METHOD', 'direct');

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
  define('ABSPATH', __DIR__ . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');