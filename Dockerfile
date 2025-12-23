ARG PHP_VERSION=8.1
ARG WP_VERSION=6.1.0
ARG WP_PATCH_VERSION=5.9.1

# WordPress resources
FROM wordpress:cli-php${PHP_VERSION} AS wp-cli
FROM wordpress:${WP_VERSION}-php${PHP_VERSION}-fpm-alpine AS wp-src



# Build rootfs
FROM scratch AS rootfs

# Install wp-cli
COPY --from=wp-cli ["/usr/local/bin/wp", "/usr/local/bin/wp-cli"]

# Install wp-utils
COPY ["./src/wp-utils/", "/usr/local/bin/"]

# Overlay
COPY ["./rootfs/", "/"]

# Configuration and patches
ARG WP_VERSION
ARG WP_PATCH_VERSION

# Copy WordPress source from the official image
COPY --from=wp-src ["/usr/src/wordpress/", "/var/www/html/"]

COPY ["patches/${WP_PATCH_VERSION}/wp-admin-update-core.patch", "/etc/wp-mods/"]

# Copy wp-content/themes to src - This is needed if wp-content is mounted as a volume and not initialized prior
COPY --from=wp-src ["/usr/src/wordpress/wp-content/themes/", "/usr/src/wordpress/wp-content/themes/"]



#-------------------------------------------------------------------------------------------------------------------
# STAGE: Build WordPress base
#-------------------------------------------------------------------------------------------------------------------
FROM ghcr.io/n0rthernl1ghts/wordpress-unit-base:2.1.0 AS wordpress-base

RUN apk add --update --no-cache patch

COPY --from=rootfs ["/", "/"]

RUN set -eux \
    && apk add --update --no-cache rsync \
    && chmod a+x /usr/local/bin/wp \
    && mv "/var/www/html/wp-config-docker.php" "/var/www/html/wp-config.php" \
    && wp-apply-patch "/etc/wp-mods/wp-admin-update-core.patch" "/var/www/html/wp-admin/update-core.php" "true" \
    && php -l /var/www/html/wp-admin/update-core.php

ARG WP_VERSION
ARG WP_PATCH_VERSION
ENV WP_VERSION="${WP_VERSION}"
ENV WP_PATCH_VERSION="${WP_PATCH_VERSION}"
ENV ENFORCE_DISABLE_WP_UPDATES=true
ENV WP_CLI_DISABLE_AUTO_CHECK_UPDATE=true
ENV CRON_ENABLED=true
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

WORKDIR "/var/www/html/"
VOLUME ["/root/.wp-cli", "/var/www/html/wp-content"]

LABEL maintainer="Aleksandar Puharic <aleksandar@puharic.com>" \
      org.opencontainers.image.documentation="https://github.com/N0rthernL1ghts/wordpress/wiki" \
      org.opencontainers.image.source="https://github.com/N0rthernL1ghts/wordpress" \
      org.opencontainers.image.description="NGINX Unit Powered WordPress ${WP_VERSION}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${WP_VERSION}"


ENTRYPOINT ["/init"]
EXPOSE 80/TCP



#-------------------------------------------------------------------------------------------------------------------
# STAGE: Build WordPress cron
#-------------------------------------------------------------------------------------------------------------------
FROM wordpress-base AS wordpress-cron

# Disable all s6 services except for svc-crond, init-docker-secrets and init-wpconfig-verify
RUN set -eux \
    && bash -c "rm -rf /etc/s6-overlay/s6-rc.d/{svc-unitd,init-unitd-configure,init-unitd-load-secrets,init-verify-wordpress,init-install-wordpress,init-install-resources,init-webuser-permissions,init-wpcontent} \
             && rm -rf /etc/s6-overlay/s6-rc.d/user/contents.d/{svc-unitd,init-unitd-configure,init-unitd-load-secrets,init-verify-wordpress,init-install-wordpress,init-install-resources,init-webuser-permissions,init-wpcontent} \
             && rm -rf /etc/s6-overlay/s6-rc.d/svc-crond/dependencies.d/{init-install-wordpress,svc-unitd}"

LABEL org.opencontainers.image.description="NGINX Unit Powered WordPress Cron ${WP_VERSION}"


ENV CRON_ENABLED=true



#-------------------------------------------------------------------------------------------------------------------
# STAGE: Build WordPress dev
#-------------------------------------------------------------------------------------------------------------------
FROM wordpress-base AS wordpress-dev-composer-build

COPY --from=composer:2.7 ["/usr/bin/composer", "/usr/local/bin/composer"]

RUN set -eux \
    && apk add --update --no-cache git unzip \
    && export COMPOSER_ALLOW_SUPERUSER=1 \
    && export COMPOSER_HOME="/tmp/composer" \
    && composer global require --no-interaction --ignore-platform-reqs \
        php-parallel-lint/php-console-highlighter \
        php-parallel-lint/php-parallel-lint \
        squizlabs/php_codesniffer



FROM scratch AS wordpress-dev-rootfs

# Install shellcheck
COPY --from=koalaman/shellcheck:stable ["/bin/shellcheck", "/usr/local/bin/shellcheck"]

# Install shfmt
COPY --from=mvdan/shfmt:latest ["/bin/shfmt", "/usr/local/bin/shfmt"]

# Install hadolint
COPY --from=hadolint/hadolint:latest ["/bin/hadolint", "/usr/local/bin/hadolint"]

# Install composer
COPY --from=wordpress-dev-composer-build ["/usr/local/bin/composer", "/usr/local/bin/"]
COPY --from=wordpress-dev-composer-build ["/tmp/composer/", "/root/.composer/"]



FROM wordpress-base AS wordpress-dev

ENV PATH="${PATH}:/root/.composer/vendor/bin"

RUN set -eux \
    && apk add --update --no-cache curl exa file fish git less nano openssh-client rsync tree unzip wget

COPY --from=wordpress-dev-rootfs ["/", "/"]

ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR "/workspace"
ENTRYPOINT ["/usr/bin/fish"]