# wordpress

WordPress docker image, powered by s6-overlay supervised NGINX Unit.

Attempt to fix several WordPress anti-patterns in a ready-to-deploy container.

---

## Architecture & Features

This image is built on top of NGINX Unit, a modern, dynamic application server, replacing the traditional NGINX + PHP-FPM combination. Independent benchmarks show that NGINX Unit handles higher concurrency and remains stable under load.

- **Supervised Services**: Controlled by [s6-overlay v3](https://github.com/just-containers/s6-overlay) for clean lifecycle management, including automated database checks, environment validation, permissions tuning, and cron execution.
- **Read-Only Core**: WordPress core files are kept read-only and core auto-updates are disabled via a code patch to ensure container lifecycle integrity and prevent discrepancies between running instances and source images.
- **Native Docker Secrets**: Secrets in `/run/secrets/` are automatically mapped to corresponding environment variables on startup.
- **Dedicated Cron Service**: Optimized variant available for running task schedulers securely without loading the web frontend.

---

## Public Builds

See [packages](../../pkgs/container/wordpress)

You can use the public builds:
```bash
ghcr.io/n0rthernl1ghts/wordpress:latest
ghcr.io/n0rthernl1ghts/wordpress-cron:latest
```

Or target a specific WordPress version:
```bash
ghcr.io/n0rthernl1ghts/wordpress:6.9.4
ghcr.io/n0rthernl1ghts/wordpress-cron:6.9.4
```
Replace the tag with your desired version (e.g., `6.6.1`).

---

## Configuration Reference

### Environment Variables

| Variable | Description | Default / Example |
| :--- | :--- | :--- |
| **Database Configuration** | | |
| `WORDPRESS_DB_HOST` | Database host hostname or IP. | `database` |
| `WORDPRESS_DB_USER` | Username to connect to the database. | `wordpress` |
| `WORDPRESS_DB_PASSWORD` | Password for the database user (highly recommended to set via Docker Secrets). | - |
| `WORDPRESS_DB_NAME` | WordPress database name. | `wordpress` |
| `WORDPRESS_TABLE_PREFIX` | Custom database table prefix. | `wp_` |
| **Object Caching (Redis)** | | |
| `WORDPRESS_CACHE` | Enable Redis cache integration (`1` or `0`). | `1` |
| `WORDPRESS_REDIS_HOST` | Redis hostname. | `cache` |
| `WORDPRESS_CACHE_KEY_SALT` | Cache key prefix salt. | `Wp-` |
| **Core & Debugging** | | |
| `WORDPRESS_DEBUG` | Toggle WordPress debug mode (`1` or `0`). | `0` |
| `WORDPRESS_CONFIG_EXTRA` | Raw PHP statements injected directly into `wp-config.php`. | See [docker-compose.yml](file:///home/xzero/workspace/private/OSS/wordpress/docker-compose.yml) |
| **Auto-Initialization** (Runs if `WORDPRESS_INIT_ENABLE` is `true`) | | |
| `WORDPRESS_INIT_ENABLE` | Set to `true` to auto-install WordPress on initial startup. | `false` |
| `WORDPRESS_INIT_SITE_URL` | Site URL for the auto-installer. | `http://localhost` |
| `WORDPRESS_INIT_SITE_TITLE` | Site title for the auto-installer. | `WordPress` |
| `WORDPRESS_INIT_ADMIN_USER` | Admin username. | `admin` |
| `WORDPRESS_INIT_ADMIN_PASSWORD` | Admin password (highly recommended to set via Docker Secrets). | - |
| `WORDPRESS_INIT_ADMIN_EMAIL` | Admin email address. | `admin@example.com` |
| `WORDPRESS_INIT_NO_SYNC_THEMES` | Disable syncing default themes to the volume if the theme folder is empty. | `false` |
| **Resource Installer** | | |
| `WORDPRESS_PLUGIN_LIST` | Space-separated list of plugins to install (with optional versions like `akismet:4.1.8`). | `maintenance redis-cache` |
| `WP_PLUGINS_INSTALL_CONCURRENCY` | Number of concurrent plugin downloads. | `5` |
| **Supervisor Control** | | |
| `CRON_ENABLED` | Toggle internal cron service (`true` / `false`). Defaults to `true` on cron image. | `true` |
| `S6_KEEP_ENV` | If set to `1`, forces s6 to keep environment variables. | `0` |

### Docker Secrets

Secrets placed in `/run/secrets/` are automatically loaded into the container environment. The following mapping is supported:

* `wordpress_db_password` &rarr; `WORDPRESS_DB_PASSWORD`
* `wordpress_init_admin_password` &rarr; `WORDPRESS_INIT_ADMIN_PASSWORD`
* `wordpress_auth_key` &rarr; `WORDPRESS_AUTH_KEY`
* `wordpress_secure_auth_key` &rarr; `WORDPRESS_SECURE_AUTH_KEY`
* `wordpress_logged_in_key` &rarr; `WORDPRESS_LOGGED_IN_KEY`
* `wordpress_nonce_key` &rarr; `WORDPRESS_NONCE_KEY`
* `wordpress_auth_salt` &rarr; `WORDPRESS_AUTH_SALT`
* `wordpress_secure_auth_salt` &rarr; `WORDPRESS_SECURE_AUTH_SALT`
* `wordpress_logged_in_salt` &rarr; `WORDPRESS_LOGGED_IN_SALT`
* `wordpress_nonce_salt` &rarr; `WORDPRESS_NONCE_SALT`

Please check [docker-compose.yml](file:///home/xzero/workspace/private/OSS/wordpress/docker-compose.yml) for a complete usage example.

---

## Cron

Cron is supported out of the box in the `ghcr.io/n0rthernl1ghts/wordpress` image, but the best practice is to use the dedicated image `ghcr.io/n0rthernl1ghts/wordpress-cron` for this purpose.

This image is optimized for running cron jobs and is stripped of web-serving and other unnecessary daemon components. Running cron in the main image is not recommended, as it can cause performance issues and lead to unexpected behavior.

---

## Resource Tooling

The image includes CLI utility scripts to query, download, unpack, and delete WordPress extensions (plugins and themes) without needing the full WP-CLI overhead.

### Plugin Installer (Runtime)

```
WARNING: This feature is experimental and can fail. Proceed with caution.
```

This container can install plugins during container startup defined in the environment variable `WORDPRESS_PLUGIN_LIST`.

If the environment variable is left empty or undefined, the installer will skip. Consider using a custom image with plugins pre-installed in order to speed up container startup and follow best practices.

Usage example:
```bash
# Notice that specific versions can be defined
WORDPRESS_PLUGIN_LIST=akismet:4.1.8 two-factor
WP_PLUGINS_INSTALL_CONCURRENCY=10
```
`WP_PLUGINS_INSTALL_CONCURRENCY` is optional and defines how many plugins can be installed in parallel (default: `5`). You should not set this to a value higher than CPU threads * 1.5.

**Caveats:**
- If a plugin was previously installed and is not defined on the list, it will NOT be removed.
- Plugins are not activated automatically; this is intentional.
- If container startup speed is crucial (e.g., start-on-demand), don't use this feature, as it blocks startup until all plugins are installed.

### Build-time Extension (Dockerfile)

You can extend the image and install plugins or themes during build time using the `wp-plugin` and `wp-theme` scripts.

#### `wp-plugin` / `wp-theme` Usage
Both commands support the following actions:
- `download <slug> [version]`
- `unpack <slug> [version]`
- `check <slug>`
- `delete <slug>`

#### Example Dockerfile:
```dockerfile
FROM ghcr.io/n0rthernl1ghts/wordpress:6.9.4 AS wp-resources-installer

RUN set -eux \
    && export WP_PLUGINS_PATH="/var/www/html/wp-content/plugins" \
    && wp-plugin download akismet 4.1.8 \
    && wp-plugin download two-factor \
    && wp-plugin download wp-mail-smtp

RUN set -eux \
    && export WP_THEMES_PATH="/var/www/html/wp-content/themes" \
    && wp-theme download twentytwentyfour \
    && wp-theme download astra 4.0.1

# Final image
FROM ghcr.io/n0rthernl1ghts/wordpress:6.9.4

# Example:
# - Install ext-redis with pecl
# - Enable ext-redis
# - Remove pear/pecl cache
# - Put production-ready php.ini in use
RUN set -eux \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && rm -rf /tmp/pear \
    && cp "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"

COPY --from=wp-resources-installer ["/var/www/html/wp-content/plugins", "/var/www/html/wp-content/plugins"]
COPY --from=wp-resources-installer ["/var/www/html/wp-content/themes", "/var/www/html/wp-content/themes"]
```

---

## End-to-End Testing

The project includes automated integration tests that deploy specific WordPress version stacks, check the initialization flow, and verify page response and integrity.

To run the tests:
1. Ensure Docker and Docker Compose are installed.
2. Run the test script from the repository root:
   ```bash
   ./hack/tests-util/e2e/run.sh
   ```

By default, the script reads all configured versions from [hack/docker-bake-common.hcl](file:///home/xzero/workspace/private/OSS/wordpress/hack/docker-bake-common.hcl) and tests them sequentially by pulling from GHCR.

You can also specify a subset of versions to test:
```bash
./hack/tests-util/e2e/run.sh 6.9.4 6.6.2
```

The script will:
* Deploy the database (MariaDB), cache (Redis), and WordPress containers.
* Wait for database and WordPress auto-initialization/installation to complete.
* Query the container to verify the running WordPress core version matches the expected version.
* Perform `curl` tests on the homepage (`/`) and administrative dashboard (`/wp-admin/`).
* Simulate user login to the administrative panel using a curl cookie jar to verify credentials work and dashboard elements render correctly.
* Attempt to trigger a core upgrade and assert that the request is successfully blocked (displaying the custom update-disabled wiki link).
* Verify HTTP status codes and scan the page bodies for PHP/database errors.
* Automatically clean up containers and volumes after each test.

---

## Deprecation Notice & Lifecycle Log

- **2026-06-16**: Dropping support for PHP 8.1 and defaulting to PHP 8.2. Deprecation of WordPress versions prior to 6.6.x.
  * Old images will remain, but will receive no further updates, until their eventual removal. Usage is discouraged.
  * Support for versions prior to 6.5 is now completely removed and images will no longer work, until their eventual removal.
- **2025-12-25**: Deprecation of WordPress versions prior to 6.5.
  * Old images will remain, but will receive no further updates, until their eventual removal. Usage is discouraged.
  * This will make build stack lighter and help work around limitations of GH hosted runners.
  * If you still need support for older versions, reach out by opening a new issue and we can see if something can be arranged.
- **2024-11-02**: Add specially optimized WordPress cron image. See [docker-compose.yml](file:///home/xzero/workspace/private/OSS/wordpress/docker-compose.yml) for usage.
- **2024-10-28**: Multiple changes:
  * Deprecate Docker Hub images.
  * Add WordPress versions 6.5.3 -> 6.6.2.
  * Add support for docker secrets.
- **2024-05-17**: Upgrade S6 supervisor to v3.
  * This is a breaking change affecting all images.
  * If your setup was vanilla, it should work out of the box.
  * If you have custom scripts, you should review them and migrate to the new format.
  * S6 supervisor v3 brings many improvements and bugfixes in addition to performance improvements.
  * This change is necessary to ensure compatibility with future base image updates.
- **2024-05-13**: Deprecation of WordPress versions prior to 6.2.
  * Old images will remain, but will receive no further updates, until their eventual removal. Usage is not recommended.
  * This decision will make build stack significantly lighter, ensuring much faster future builds.
- **2023-08-06**: Deprecation/removal of linux/armhf architecture.
  * 32-bit ARM is officially dead.
  * It has been deprecated/removed in the base.
  * This improves build speed as building linux/armhf is slow and was taking most of the time.
  * Simplifies maintenance.
- **2023-04-09**: Deprecation of docker.io hosted images. We're moving to ghcr.io.
  * This is due to Docker Hub's sunsetting of free teams. See docker/hub-feedback#2314.
  * If you are using `nlss/wordpress` images, you should switch to `ghcr.io/n0rthernl1ghts/wordpress`.
  * `nlss/wordpress` images will be removed in May. Further usage is not recommended, although we'll keep them up to date until then.
- **2023-01-23**: WordPress is no longer installed during runtime and it's bundled into the image.
  * This renders `WP_LOCALE` environment variable useless.
  * Instead, you will be offered to select locale during the first setup.
- **2023-01-22**: Replace NGINX + PHP-FPM combo with NGINX Unit.
  * Split and rebase image and rework build.
  * This is a breaking change affecting all images.
  * If your setup was vanilla, it should work out of the box.
  * If you need nginx, you can set it up as a reverse proxy.
  * NGINX Unit is modern application server, replacing old PHP-FPM.
  * Independent benchmarks have shown that NGINX Unit can handle much higher load and remain stable.
- **2023-01-21**: Retirement of PHP 7.4.
- **2023-01-20**: Deprecation of WordPress versions prior to 5.9.
  * Preparation for PHP 8.1 upgrade.
  * WordPress versions prior to 5.9 have no PHP 8.1 support.
  * PHP 8.0 active support has ended since 2022-11-28, therefore skipping this release.
  * PHP 7.4 reached end-of-life on 2022-11-28 and should not be used.
  * Old images will remain, but will receive no further updates, until their eventual removal. Usage is not recommended.
  * This decision will make build stack significantly lighter, ensuring much faster future builds.

---

## TODO

* ~Disable core updates~
* ~Install/update plugins on the fly using wp cli (with versioning)~
* Install/update themes on the fly using wp cli (with versioning)
* ~Apply theme and eventual plugin customizations using patch files~ (Partial)
* ~Support automatic install using ENV~
* Create users automatically using ENV
* Support non-blocking plugin installation
