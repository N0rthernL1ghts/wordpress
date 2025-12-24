# wordpress
WordPress docker image, powered by s6 supervised nginx unit.

Attempt to fix several of WordPress anti-patterns in ready to deploy container.

Native support for docker secrets! Secrets are automatically imported into the container environment.  
No more need for `_FILE` suffixed environment variables. Still, you're free to use whichever way you want, but using secrets like this is highly encouraged.  
Please check docker-compose.yml for usage example.

#### Deprecation notice
- 2023-01-20 Deprecation of WordPress versions prior to 5.9
  * Preparation for PHP8.1 upgrade.
  * WordPress versions prior to 5.9 have no PHP8.1 support.
  * PHP8.0 active support has ended since 2022-11-28, therefore skipping this release
  * PHP7.4 reached end-of-life on 2022-11-28 and should not be used.
  * Old images will remain, but will receive no further updates, until their eventual removal. Usage is not recommended.
  * This decision will make build stack significantly lighter, ensuring much faster future builds
- 2023-01-21 Retirement of PHP7.4. The king is dead, long live the king!
- 2023-01-22 Replace NGINX + PHP-FPM combo with NGINX Unit
  * Split and rebase image and rework build
  * This is breaking change affecting all images
  * If your setup was vanilla, it should work out of the box
  * If you need nginx, you can set it up as a reverse proxy
  * NGINX Unit is modern application server, replacing old PHP-FPM
  * Independent benchmarks have show that NGINX Unit can handle much higher load and remain stable
- 2023-01-23 WordPress is no longer installed during runtime and it's bundled into the image
  * This renders WP_LOCALE environment variable useless
  * Instead, you will be offered to select locale during the first setup
- 2023-04-09 Deprecation of docker.io hosted images. We're moving to ghcr.io.
  * This is due to Docker Hub's sunsetting of free teams. See docker/hub-feedback#2314
  * If you are using nlss/wordpress images, you should switch to ghcr.io/n0rthernl1ghts/wordpress
  * nlss/wordpress images will be removed in May. Further usage is not recommended, although we'll keep them up to date until then.
- 2023-08-06 Deprecation/removal of linux/armhf architecture
  * 32-bit ARM is [officialy dead](https://www.androidauthority.com/arm-32-vs-64-bit-explained-1232065/).
  * It has been deprecated/removed in the base
  * This improves build speed as buidling linux/armhf is slow and was taking the most of the time
  * Simplifies maintenance
- 2024-05-13 Deprecation of WordPress versions prior to 6.2
  * Old images will remain, but will receive no further updates, until their eventual removal. Usage is not recommended.
  * This decision will make build stack significantly lighter, ensuring much faster future builds
- 2024-05-17 Upgrade S6 supervisor to v3
  * This is breaking change affecting all images
  * If your setup was vanilla, it should work out of the box
  * If you have custom scripts, you should review them and migrate to new format
  * S6 supervisor v3 brings many improvements and bugfixes in addition to performance improvements
  * This change is necessary to ensure compatibility with future base image updates
- 2024-10-28 Multiple changes
  * Deprecate docker hub images
  * Add WordPress versions 6.5.3 -> 6.6.2
  * Add support for docker secrets
- 2024-11-02 Add specially optimized WordPress cron image. See docker-compose.yml for usage
- 2025-12-25 Deprecation of WordPress versions prior to 6.5
  * Old images will remain, but will receive no further updates, until their eventual removal. Usage is discouraged.
  * This will make build stack lighter and help work around limitations of GH hosted runners.
  * If you still need support for older versions, reach out by opening new issue and we can see if something can be arranged

#### Public builds (docker)

See: [packages](../../pkgs/container/wordpress)

You can use public build:
```
ghcr.io/n0rthernl1ghts/wordpress:latest
ghcr.io/n0rthernl1ghts/wordpress-cron:latest
```

You can also use specific version of WordPress:
```
ghcr.io/n0rthernl1ghts/wordpress:6.6.2
ghcr.io/n0rthernl1ghts/wordpress-cron:6.6.2
```

Replace version number with desired version, eg. 6.6.1.

#### Cron
Cron is supported out of the box in `ghcr.io/n0rthernl1ghts/wordpress` image, but the best practice is to use dedicated image `ghcr.io/n0rthernl1ghts/wordpress-cron` for this purpose. <br/>
This image is optimized for running cron jobs, and is stripped of unnecessary components.

Running cron in the main image is not recommended, as it can cause performance issues, and can lead to unexpected behavior.

#### Plugin installer

```
WARNING: This feature is experimental and can fail. Proceed with caution
```

This container can install plugins during container startup defined in environment variable WORDPRESS_PLUGIN_LIST

If environment variable is left empty, or undefined, installer will skip.<br/>
Consider using custom image with plugins pre-installed in order to speed up container startup, and follow the best practices.


Usage example:
```
# Notice that specific version can be defined
WORDPRESS_PLUGIN_LIST=akismet:4.1.8 two-factor
WP_PLUGINS_INSTALL_CONCURRENCY=10
```
`WP_PLUGINS_INSTALL_CONCURRENCY` is optional, and defines how many plugins can be installed in parallel. Default is 5. <br/>
If you have a lot of plugins, you can increase this value to speed up installation, but be aware that this can cause issues, such as overloaded network connection, or even server overload. <br/>
You should not set this value to value higher than number of CPU threads ( * 1.5 ).

Caveats:
* If plugin was previously installed, and not defined on the list, it will NOT be removed.
* Plugins are not activated automatically; This is intentional.
* If container startup speed is crucial (eg. start-on-demand ), don't use this feature, as it will block container startup until all plugins are installed.

#### Extending image
You can extend this image and install plugins during build time, using `wp-plugin` script. <br/>

Example:
```Dockerfile
FROM ghcr.io/n0rthernl1ghts/wordpress:6.7.1 AS wp-plugins-installer

RUN set -eux \
    && export WP_PLUGINS_PATH="/var/www/html/wp-content/plugins" \
    && wp-plugin download akismet 4.1.8 \
    && wp-plugin download two-factor \
    && wp-plugin download wp-mail-smtp

# Final image
FROM ghcr.io/n0rthernl1ghts/wordpress:6.7.1

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

COPY --from=wp-plugins-installer ["/var/www/html/wp-content/plugins", "/var/www/html/wp-content/plugins"]
```

### TODO
* ~Disable core updates~
* ~Install/update plugins on the fly using wp cli (with versioning)~
* Install/update themes on the fly using wp cli (with versioning)
* ~Apply theme and eventual plugin customizations using patch files~ (Partial)
* ~Support automatic install using ENV~
* Create users automatically using ENV
* Support non-blocking plugin installation
