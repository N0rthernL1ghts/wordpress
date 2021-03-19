#!/usr/bin/env sh
set -e

echo "> Building helper image..."
docker build -t local/wp-patch-util .
mkdir wp-src/ -p
echo ""
echo "> Running helper container..."

USER_ID=$(id -u "${USER}")
GROUP_ID=$(id -g "${USER}")

docker run --rm -t --name="wp-patch-util-$(date +%s)" -v "${PWD}/wp-src:/wp/src" -e "UID=${USER_ID}" -e "GID=${GROUP_ID}" local/wp-patch-util
sudo chown "${USER}:${USER}" wp-src -R
echo ""
echo ""
echo "> Two files are now downloaded to wp-src"
echo "> Please update wp-src/mod-update-core.php with code bellow  and then execute ./01-create-patch.sh"
echo ""
echo ""
echo "wp_die("
echo "      __( 'Sorry, you are not allowed to update this site.' ) ."
echo "      ' Click <a href=\"https://github.com/N0rthernL1ghts/wordpress/wiki/WordPress-Core-Updates\">here</a> to learn why.'"
echo ");"
echo ""