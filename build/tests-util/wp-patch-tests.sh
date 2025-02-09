#!/usr/bin/env bash

# Register exit handler
trap scriptExitHandler EXIT

function scriptExitHandler() {
    local lastExitCode=$?

    if [ "${lastExitCode}" = "0" ]; then
        echo "> Script finished successfully"
        exit "${lastExitCode}"
    fi

    echo "> Script finished with an error"
    return "${lastExitCode}"
}

function getFileCount() {
    ALL_DIRECTORIES=("${1:?Target dir is required}"/*)
    echo ${#ALL_DIRECTORIES[@]} # Sometimes, you just need a count
}

function taskPrepareWpPatch() {
    local patchDir="${1:?}"
    local downloadRoot="${2:?}"


    local wpLongVersion
    local wpShortVersion
    local downloadPath
    wpLongVersion="$(basename "${patchDir}")"
    wpShortVersion="$(echo "${wpLongVersion}" | sed --expression='s/.0$//g')"
    downloadPath="${downloadRoot}/${wpLongVersion}"

    mkdir -p "${downloadPath}"

    # Download WordPress
    wp --allow-root core download --locale="en_GB" --version="${wpShortVersion}" --path="${downloadPath}"

    echo "> Applying patch"
    patch "${downloadPath}/wp-admin/update-core.php" <"${patchDir}/wp-admin-update-core.patch"
    mv -v "${downloadPath}/wp-admin/update-core.php" "${PHP_TESTS_DIR}/update-core-${wpLongVersion}.php"

    rm "${downloadPath}" -rf
}

main() {
    PHP_TESTS_DIR="/data/test_files"
    export PHP_TESTS_DIR

    mkdir -p "${PHP_TESTS_DIR}"

    local patchDir

    # For each patch, download appropriate WP version, apply patch and check if file syntax is correct afterwards
    for patchDir in patches/*/; do
        echo "> Deploying task ${patchDir}"

        # Introduce ~50ms overhead before deploying another task
        # Even shorter overhead helps. but better to be on safe side.
        # This should prevent concurrency issues
        sleep 0.05

        # Run task concurrently
        taskPrepareWpPatch "${patchDir}" "/data/wp_src" &
    done

    echo "Waiting for all tasks to finish..."
    wait

    # Make sure that directory is not empty
    if [ ! "$(ls -A "${PHP_TESTS_DIR}")" ]; then
        echo "Error: Target directory is empty"
        return 1
    fi

    local numberOfPatches
    local numberOfTestFiles
    numberOfPatches="$(getFileCount patches)"
    numberOfTestFiles="$(getFileCount "${PHP_TESTS_DIR}")"

    if [ "${numberOfPatches}" != "${numberOfTestFiles}" ]; then
        echo "> Error - Unexpected number of files"
        echo "  Expected: ${numberOfPatches}"
        echo "    Actual: ${numberOfTestFiles}"
        return 1
    fi

    # Run php-lint on resulting patch files
    php-parallel-lint "${PHP_TESTS_DIR}" -s --blame --exclude vendor -p php
    return $?
}

main "${@}"
