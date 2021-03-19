#!/usr/bin/env sh

MOD_FILE="mod-update-core.php"
TARGET_FILE="update-core.php"
PATCH_FILE="update-core.php.patch"

set -e
cd ./wp-src

if [ ! -f "${MOD_FILE}" ]; then
  echo "X ${MOD_FILE} not found"
  exit 1
fi

if [ ! -f "${TARGET_FILE}" ]; then
  echo "X ${TARGET_FILE} not found"
  exit 1
fi

if cmp --silent "${MOD_FILE}" "${TARGET_FILE}"; then
  echo "X ${MOD_FILE} and ${TARGET_FILE} are the same. Nothing to patch."
  exit 1
fi

if [ -f "${PATCH_FILE}" ]; then
  PATCH_FILE_BACKUP="$(date +%s)bak-${PATCH_FILE}"
  echo "! Patch file ${PATCH_FILE} already exists and will be backed up"
  mv "${PATCH_FILE}" "${PATCH_FILE_BACKUP}"
  echo "! Backup: ${PATCH_FILE_BACKUP}"
fi

# diff exits with code 1 if there was a difference between files, so we need to temporarily disable exit-on-error
set +e
echo "> Patching file..."
diff -u "${TARGET_FILE}" "${MOD_FILE}" > "${PATCH_FILE}"
set -e

if [ ! -s "${PATCH_FILE}" ]; then
  echo "X Patch failed."
  exit 1
fi

echo "> Fixing patch header"
sed -i "s/${MOD_FILE}/${TARGET_FILE}/g" "${PATCH_FILE}"

echo "> Patch file created ${PATCH_FILE}"
echo "> Please run: "
echo "  cp './wp-src/${PATCH_FILE}' '../../rootfs/etc/wp-mods/wp-admin/'"
echo ""
echo "> Don't forget to commit the changes"
echo "> Finished"