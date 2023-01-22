ARG PHP_VERSION=8.1
ARG WP_VERSION=6.1.0

# WP CLI
FROM --platform=${TARGETPLATFORM} wordpress:cli-php${PHP_VERSION} AS wp-cli


# Build rootfs
FROM scratch AS rootfs

# Install wp-cli
COPY --from=wp-cli ["/usr/local/bin/wp", "/usr/local/bin/wp-cli"]

# Overlay
COPY ["./rootfs/", "/"]

# Configuration and patches
ARG WP_VERSION
COPY ["wp-config.php",                                    "/var/www/html/"]
COPY ["patches/${WP_VERSION}/wp-admin-update-core.patch", "/etc/wp-mods/"]


# Stage 3 - Final
FROM --platform=${TARGETPLATFORM} nlss/wordpress-unit-base:1.0.0

RUN apk add --update --no-cache patch

COPY --from=rootfs ["/", "/"]

RUN chmod a+x /usr/local/bin/wp

ARG WP_VERSION
ENV WP_VERSION="${WP_VERSION}"
ARG WP_LOCALE="en_US"
ENV WP_LOCALE=${WP_LOCALE}
ENV ENFORCE_DISABLE_WP_UPDATES=true
ENV WP_CLI_DISABLE_AUTO_CHECK_UPDATE=true
ENV CRON_ENABLED=true
ENV WEB_ROOT=html

WORKDIR "/var/www/${WEB_ROOT}/"
VOLUME ["/root/.wp-cli", "/var/www/${WEB_ROOT}", "/var/www/${WEB_ROOT}/wp-content"]

LABEL maintainer="Aleksandar Puharic <aleksandar@puharic.com>"
ENTRYPOINT ["/init"]
EXPOSE 80/TCP
