ARG WP_VERSION=5.4.2
FROM wordpress:${WP_VERSION}-php7.4-fpm-alpine AS wordpress-builder

USER root

WORKDIR /tmp/build/rootfs

# Build root filesystem structure (overlay), and copy over neccessary files
RUN    mkdir -p usr/local/bin \
    && mkdir -p usr/local/etc/php/conf.d/ \
    && mv /usr/local/etc/php/conf.d/error-logging.ini       usr/local/etc/php/conf.d/ \
    && mv /usr/local/etc/php/conf.d/opcache-recommended.ini usr/local/etc/php/conf.d/


################################################# APP ##################################################################
FROM nlss/php-nginx
ARG WP_VERSION
ENV APK_DEPS        "zlib-dev libzip-dev libpng-dev icu-dev imagemagick-dev"
ENV APK_BUILD_DEPS  "curl-dev autoconf alpine-sdk"
ENV APK_WP_CLI_DEPS "bash less mysql-client"

RUN apk add --update --no-cache ${APK_WP_CLI_DEPS} ${APK_DEPS} ${APK_BUILD_DEPS}  \
    && docker-php-ext-install -j "$(nproc)" \
          bcmath \
       		exif \
       		gd \
       		mysqli \
       		opcache \
       		zip \
       		intl \
    && pecl install redis apcu imagick-3.4.4 \
    && docker-php-ext-enable redis apcu imagick \
    && apk del ${APK_BUILD_DEPS} \
    && rm /tmp/* -rf

ADD rootfs /
COPY ["wp-config.php", "/var/www/html"]
COPY --from=wordpress-builder    /tmp/build/rootfs /
COPY --from=wordpress:cli-php7.4 /usr/local/bin/wp /usr/local/bin/wp-cli

ENV WP_CONTENT_ID         2bca7d694c6279bb79bbb642ba4305f9
ENV WP_VERSION            ${WP_VERSION}
ENV WP_LOCALE             en_US
ENV CRON_ENABLED          true
ENV VIRTUAL_HOST          your-domain.com

RUN echo "* * * * * /usr/local/bin/php /var/www/${WEB_ROOT}/wp-cron.php" >> /etc/crontabs/www-data

VOLUME ["/var/www/${WEB_ROOT}", "/var/www/${WEB_ROOT}/wp-content"]

EXPOSE 80/TCP