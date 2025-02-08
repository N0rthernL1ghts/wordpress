#!/usr/bin/env bash

# Register exit handler
trap scriptExitHandler EXIT

function scriptExitHandler() {
    LAST_EXIT_CODE=$?

    if [ -n "${WP_DL_TEMP_DIR}" ] && [ -d "${WP_DL_TEMP_DIR}" ]; then
        rm -rf "${WP_DL_TEMP_DIR:?}"
    fi

    if [ -n "${PHP_TESTS_TEMP_DIR}" ] && [ -d "${PHP_TESTS_TEMP_DIR}" ]; then
        rm -rf "${PHP_TESTS_TEMP_DIR:?}"
    fi

    if [ "${LAST_EXIT_CODE}" = "0" ]; then
        echo "> Script finished successfully"
        exit "${LAST_EXIT_CODE}"
    fi

    echo "> Script finished with an error"
    return "${LAST_EXIT_CODE}"
}

function getFileCount() {
    ALL_DIRECTORIES=("${1:?Target dir is required}"/*)
    echo ${#ALL_DIRECTORIES[@]} # Sometimes, you just need a count
}

function taskPrepareWpPatch() {
    WP_DL_TEMP_DIR="$(mktemp -d -t XXXXXXXXXXX)"
    PATCH_DIR=${1:?}

    WP_WORK_LONG_VERSION="$(basename "${PATCH_DIR}")"
    WP_WORK_SHORT_VERSION="$(echo "${WP_WORK_LONG_VERSION:?}" | sed --expression='s/.0$//g')"
    wp --allow-root core download --locale="en_GB" --version="${WP_WORK_SHORT_VERSION}" --path="${WP_DL_TEMP_DIR}"

    echo "> Applying patch"
    patch "${WP_DL_TEMP_DIR}/wp-admin/update-core.php" <"${PATCH_DIR}/wp-admin-update-core.patch"
    mv -v "${WP_DL_TEMP_DIR}/wp-admin/update-core.php" "${PHP_TESTS_TEMP_DIR}/update-core-${WP_WORK_LONG_VERSION}.php"

    rm "${WP_DL_TEMP_DIR?}" -rf
}

main() {
    PHP_TESTS_TEMP_DIR="$(mktemp -d -t XXXXXXXXXXX)"
    export PHP_TESTS_TEMP_DIR

    local patchDir

    # For each patch, download appropriate WP version, apply patch and check if file syntax is correct afterwards
    for patchDir in patches/*/; do
        echo "> Deploying task ${patchDir}"

        # Introduce ~50ms overhead before deploying another task
        # Even shorter overhead helps. but better to be on safe side.
        # This should prevent concurrency issues
        sleep 0.05

        # Run task concurrently
        taskPrepareWpPatch "${patchDir}" &
    done

    echo "Waiting for all tasks to finish..."
    wait

    # Make sure that directory is not empty
    if [ ! "$(ls -A "${PHP_TESTS_TEMP_DIR}")" ]; then
        echo "Error: Target directory is empty"
        return 1
    fi

    local numberOfPatches
    local numberOfTestFiles
    numberOfPatches="$(getFileCount patches)"
    numberOfTestFiles="$(getFileCount "${PHP_TESTS_TEMP_DIR}")"

    if [ "${numberOfPatches}" != "${numberOfTestFiles}" ]; then
        echo "> Error - Unexpected number of files"
        echo "  Expected: ${numberOfPatches}"
        echo "    Actual: ${numberOfTestFiles}"
        return 1
    fi

    # Run php-lint on resulting patch files
    php-parallel-lint "${PHP_TESTS_TEMP_DIR}" -s --blame --exclude vendor -p php
    return $?
}

main "${@}"
