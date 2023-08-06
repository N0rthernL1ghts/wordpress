ARG PHP_VERSION=8.1
ARG WP_VERSION=6.1.0
ARG WP_PATCH_VERSION=5.9.1

# WordPress resources
FROM --platform=${TARGETPLATFORM} wordpress:cli-php${PHP_VERSION} AS wp-cli
FROM --platform=${TARGETPLATFORM} wordpress:${WP_VERSION}-php${PHP_VERSION}-fpm-alpine AS wp-src



# Build rootfs
FROM scratch AS rootfs

# Install wp-cli
COPY --from=wp-cli ["/usr/local/bin/wp", "/usr/local/bin/wp-cli"]

# Overlay
COPY ["./rootfs/", "/"]

# Configuration and patches
ARG WP_VERSION
ARG WP_PATCH_VERSION

# Copy WordPress source from the official image
COPY --from=wp-src ["/usr/src/wordpress/", "/var/www/html/"]

COPY ["patches/${WP_PATCH_VERSION}/wp-admin-update-core.patch", "/etc/wp-mods/"]


# Stage 3 - Final
FROM --platform=${TARGETPLATFORM} nlss/wordpress-unit-base:1.0.0

RUN apk add --update --no-cache patch

COPY --from=rootfs ["/", "/"]

RUN set -eux \
    && chmod a+x /usr/local/bin/wp \
    && mv "/var/www/html/wp-config-docker.php" "/var/www/html/wp-config.php" \
    && wp-apply-patch "/etc/wp-mods/wp-admin-update-core.patch" "/var/www/html/wp-admin/update-core.php" "true"

ARG WP_VERSION
ARG WP_PATCH_VERSION
ENV WP_VERSION="${WP_VERSION}"
ENV WP_PATCH_VERSION="${WP_PATCH_VERSION}"
ENV ENFORCE_DISABLE_WP_UPDATES=true
ENV WP_CLI_DISABLE_AUTO_CHECK_UPDATE=true
ENV CRON_ENABLED=true

WORKDIR "/var/www/html/"
VOLUME ["/root/.wp-cli", "/var/www/html/wp-content"]

LABEL maintainer="Aleksandar Puharic <aleksandar@puharic.com>" \
      org.opencontainers.image.documentation="https://github.com/N0rthernL1ghts/wordpress/wiki" \
      org.opencontainers.image.source="https://github.com/N0rthernL1ghts/wordpress" \
      org.opencontainers.image.description="nginx-unit Powered WordPress ${WP_VERSION} - Build ${TARGETPLATFORM}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${WP_VERSION}"


ENTRYPOINT ["/init"]
EXPOSE 80/TCP
