ARG PHP_VERSION=7.4
ARG WP_VERSION=5.8.0


# Stage 1 - wordpress
FROM --platform=${TARGETPLATFORM} wordpress:${WP_VERSION}-php${PHP_VERSION}-fpm-alpine AS wordpress


# Stage 2 - Build rootfs
FROM scratch AS wordpress-rootfs

COPY --from=wordpress ["/usr/local/etc/php/conf.d",     "/usr/local/etc/php/conf.d/"]
COPY --from=wordpress ["/usr/local/etc/php-fpm.d",      "/usr/local/etc/php-fpm.d/"]
COPY --from=wordpress ["/usr/local/include/php/ext",    "/usr/local/include/php/ext/"]
COPY --from=wordpress ["/usr/local/lib/php/extensions", "/usr/local/lib/php/extensions/"]
COPY --from=wordpress ["/usr/local/lib/php/test",       "/usr/local/lib/php/test/"]


# Stage 3 - Final
FROM --platform=${TARGETPLATFORM} nlss/php-nginx:${PHP_VERSION}
# As long as new version doesn't require changes to Dockerfile, we don't need separate files

ENV APK_RUNTIME_DEPS      "zlib-dev libzip-dev libpng-dev icu-dev imagemagick-dev libjpeg libgomp patch"
ENV APK_WP_CLI_DEPS       "bash less mysql-client"
RUN apk add --update --no-cache ${APK_WP_CLI_DEPS} ${APK_RUNTIME_DEPS} 


COPY --from=wordpress-rootfs     / /
COPY --from=wordpress:cli-php7.4 /usr/local/bin/wp /usr/local/bin/wp-cli

ARG WP_VERSION
ENV WP_VERSION            ${WP_VERSION}
ENV WP_LOCALE             en_US
ENV CRON_ENABLED          true
ENV VIRTUAL_HOST          your-domain.com

ADD rootfs /
RUN echo "*/5 * * * * /usr/local/bin/wp cron event run --due-now" >> /etc/crontabs/www-data \
    && chmod a+x /usr/local/bin/wp

VOLUME ["/root/.wp-cli", "/var/www/${WEB_ROOT}", "/var/www/${WEB_ROOT}/wp-content"]

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2
ENV ENFORCE_DISABLE_WP_UPDATES   true
ENV WP_CLI_DISABLE_AUTO_CHECK_UPDATE true

COPY ["wp-config.php", "/var/www/html"]
COPY ["patches/${WP_VERSION}/wp-admin-update-core.patch", "/etc/wp-mods/"]

EXPOSE 80/TCP
