FROM wordpress:cli-php7.4 AS wordpress-builder

USER root

COPY ["rootfs", "/"]
WORKDIR "/wp"

ENV UID 1000
ENV GID 1000
ENV WP_LOCALE "en_US"
ENV WP_VERSION "5.7.1"

ENTRYPOINT ["/wp/entrypoint.sh"]
