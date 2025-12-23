ARG PHP_VERSION=8.1
ARG WP_VERSION=6.0.2


# Build composer dependencies
FROM composer AS builder

WORKDIR "/var/www/composer/"
COPY ["./composer.json", "/var/www/composer/"]

RUN set -eux \
    && composer install --dev --no-interaction --ignore-platform-reqs



# Build/tag WPCLI
FROM wordpress:cli-php${PHP_VERSION} AS wp-cli



# Build root filesystem
FROM scratch AS rootfs

COPY --from=builder ["/usr/bin/composer", "/usr/local/bin/"]
COPY --from=builder ["/var/www/composer", "/var/www/composer/"]

# Install wp-cli
COPY --from=wp-cli ["/usr/local/bin/wp", "/usr/local/bin/wp"]

# WP patch tests
COPY --chmod=0777 ["./wp-patch-tests.sh", "/usr/local/bin/wp-patch-tests"]

# Build final image
ARG PHP_VERSION
ARG WP_VERSION
FROM wordpress:${WP_VERSION}-php${PHP_VERSION}-fpm-alpine


RUN set -eux \
    && apk add --update --no-cache gawk git grep patch less \
    && git config --global --add safe.directory /var/www/html \
    && echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/memory-limit.ini \
    && ln -sf /var/www/composer/vendor/bin/parallel-lint /usr/local/bin/php-parallel-lint

COPY --from=rootfs ["/", "/"]

WORKDIR /data
