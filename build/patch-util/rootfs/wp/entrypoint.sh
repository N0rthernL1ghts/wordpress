#!/usr/bin/env sh

echo "> Downloading WordPress ${WP_VERSION} ..."

# Removes trailing zero if found
WP_SHORT_VERSION=$(echo "${WP_VERSION}" | sed --expression='s/.0$//g');
echo "> Short Version: ${WP_SHORT_VERSION}"

wp --allow-root --path="/tmp" core download --locale="${WP_LOCALE}" --version="${WP_SHORT_VERSION}"

if [ ! -f "/tmp/wp-admin/update-core.php" ]; then
  echo "X WordPress download failed"
  exit 1
fi

mkdir src -p
rm src/* -f

cp /tmp/wp-admin/update-core.php src/
cp src/update-core.php src/mod-update-core.php

echo "> Files ready."

exit 0
