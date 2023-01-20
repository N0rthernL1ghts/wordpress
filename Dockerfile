ARG PHP_VERSION=7.4
ARG WP_VERSION=6.1.0

# WP CLI
FROM --platform=${TARGETPLATFORM} wordpress:cli-php${PHP_VERSION} AS wp-cli


# Build rootfs
FROM scratch AS rootfs

# Install wp-cli
COPY --from=wp-cli ["/usr/local/bin/wp", "/usr/local/bin/wp-cli"]

# Install attr utility
COPY --from=nlss/attr ["/usr/local/bin/attr", "/usr/local/bin/"]

# Add crond service
COPY --from=nlss/base-alpine:3.14 ["/etc/services.d/cron/", "/etc/services.d/cron/"]

# Add nginx service and configuration
COPY --from=nlss/php-nginx:7.4 ["/etc/services.d/nginx/", "/etc/services.d/nginx/"]
COPY --from=nlss/php-nginx:7.4 ["/etc/nginx/",            "/etc/nginx/"]
COPY --from=nlss/php-nginx:7.4 ["/var/log/nginx/",        "/var/log/nginx/"]
COPY --from=nlss/php-nginx:7.4 ["/var/www/",              "/var/www/"]

# Install gomplate
COPY --from=hairyhenderson/gomplate:v3.10.0-alpine ["/bin/gomplate", "/usr/local/bin/"]

# Install s6 supervisor
COPY --from=nlss/s6-rootfs:2.2 ["/", "/"]

# Overlay
COPY ["./rootfs/", "/"]

# Configuration and patches
ARG WP_VERSION
COPY ["wp-config.php",                                    "/var/www/html/"]
COPY ["patches/${WP_VERSION}/wp-admin-update-core.patch", "/etc/wp-mods/"]


# Stage 3 - Final
FROM --platform=${TARGETPLATFORM} wordpress:${WP_VERSION}-php${PHP_VERSION}-fpm-alpine

RUN apk add --update --no-cache patch less mysql-client tzdata

COPY --from=rootfs ["/", "/"]

RUN mv /etc/nginx/conf.d /etc/nginx/http.d \
    && apk add --update --no-cache nginx \
    && echo "*/5 * * * * /usr/local/bin/wp cron event run --due-now" >> /etc/crontabs/www-data \
    && chmod a+x /usr/local/bin/wp

ARG WP_VERSION
ENV WP_VERSION="${WP_VERSION}"
ARG WP_LOCALE="en_US"
ENV WP_LOCALE=${WP_LOCALE}
ENV VIRTUAL_HOST=your-domain.com
ENV S6_KEEP_ENV=1
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV ENFORCE_DISABLE_WP_UPDATES=true
ENV WP_CLI_DISABLE_AUTO_CHECK_UPDATE=true
ENV CRON_ENABLED=true
ENV WEB_ROOT=html

WORKDIR "/var/www/${WEB_ROOT}/"
VOLUME ["/root/.wp-cli", "/var/www/${WEB_ROOT}", "/var/www/${WEB_ROOT}/wp-content"]

ENTRYPOINT ["/init"]
EXPOSE 80/TCP
