ARG PHP_VERSION=7.4
ARG WP_VERSION=5.8.0
FROM --platform=${TARGETPLATFORM} wordpress:${WP_VERSION}-php${PHP_VERSION}-fpm-alpine AS wordpress-builder

USER root

WORKDIR /tmp/build/rootfs

# Build root filesystem structure (overlay), and copy over neccessary files
RUN    mkdir -p usr/local/bin \
    && mkdir -p usr/local/etc/php/conf.d/ \
    && mv /usr/local/etc/php/conf.d/error-logging.ini       usr/local/etc/php/conf.d/ \
    && mv /usr/local/etc/php/conf.d/opcache-recommended.ini usr/local/etc/php/conf.d/


################################################# APP ##################################################################
FROM --platform=${TARGETPLATFORM} nlss/php-nginx:${PHP_VERSION}
ARG WP_VERSION
ENV APK_DEPS        "zlib-dev libzip-dev libpng-dev icu-dev imagemagick-dev patch"
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

COPY --from=wordpress-builder    /tmp/build/rootfs /
COPY --from=wordpress:cli-php7.4 /usr/local/bin/wp /usr/local/bin/wp-cli


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

EXPOSE 80/TCP
