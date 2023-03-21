FROM wordpress:cli-php8.1 AS wordpress-builder

USER root

COPY ["rootfs", "/"]
WORKDIR "/wp"

ENV UID 1000
ENV GID 1000
ENV WP_LOCALE="en_US"
ARG WP_VERSION="6.0.2"
ENV WP_VERSION="${WP_VERSION}"

ENTRYPOINT ["/wp/entrypoint.sh"]
