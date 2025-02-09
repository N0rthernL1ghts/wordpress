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
    set -eou pipefail

    local wpLongVersion="${1:?}"
    local patchDir="${2:?}"
    local downloadRoot="${3:?}"

    # Define variables
    local wpShortVersion
    local downloadPath

    wpShortVersion="$(echo "${wpLongVersion}" | sed --expression='s/.0$//g')"
    downloadPath="${downloadRoot}/${wpLongVersion}"

    mkdir -p "${downloadPath}"

    # Download WordPress
    wp --allow-root core download --locale="en_GB" --version="${wpShortVersion}" --path="${downloadPath}"

    echo "> Applying patch"
    patch "${downloadPath}/wp-admin/update-core.php" <"${patchDir}/wp-admin-update-core.patch"
    cp -v "${downloadPath}/wp-admin/update-core.php" "${PHP_TESTS_DIR}/update-core-${wpLongVersion}.php"

    rm "${downloadPath}" -rf
}

function extractVersionsFromHCL() {
    local hclFile="${1:?HCL file path required}"

    gawk '
        /args *= *get-args/ {
            if (match($0, /get-args\("([0-9]+\.[0-9]+\.[0-9]+)", *"([0-9]+\.[0-9]+\.[0-9]+)"\)/, arr)) {
                print arr[1], arr[2];
            }
        }
    ' "${hclFile}"
}

main() {
    PHP_TESTS_DIR="/data/test_files"
    export PHP_TESTS_DIR

    mkdir -p "${PHP_TESTS_DIR}"

    local patchDir

    local wpLongVersion
    local wpPatchVersion
    local expectedPatchCount=0

    declare -a versions
    mapfile -t versions < <(extractVersionsFromHCL /data/docker-bake.hcl)

    for version in "${versions[@]}"; do
        wpLongVersion=$(echo "$version" | awk '{print $1}')
        wpPatchVersion=$(echo "$version" | awk '{print $2}')
        patchDir="/data/patches/${wpPatchVersion}"
        printf "Deploying task [Version: %s, Patch: %s, Path: %s]\n" "${wpLongVersion}" "${wpPatchVersion}" "${patchDir}"

        # Introduce ~50ms overhead before deploying another task
        # Even shorter overhead helps. but better to be on safe side.
        # This should prevent concurrency issues
        sleep 0.05

        if [ ! -d "${patchDir}" ]; then
            printf "Error: Patch directory not found: %s\n" "${patchDir}"
            return 1
        fi

        # Start the task in the background and capture the PID
        taskPrepareWpPatch "${wpLongVersion}" "${patchDir}" "/data/wp_src" &
        ((expectedPatchCount++))
    done

    echo "Waiting for all tasks to complete..."
    wait

    # Make sure that directory is not empty
    if [ ! "$(ls -A "${PHP_TESTS_DIR}")" ]; then
        echo "Error: Target directory is empty"
        return 1
    fi

    local numberOfTestFiles
    numberOfTestFiles="$(getFileCount "${PHP_TESTS_DIR}")"

    if [ "${expectedPatchCount}" != "${numberOfTestFiles}" ]; then
        echo "> Error - Unexpected number of files"
        echo "  Expected: ${expectedPatchCount}"
        echo "    Actual: ${numberOfTestFiles}"
        return 1
    fi

    # Run php-lint on resulting patch files
    if php-parallel-lint "${PHP_TESTS_DIR}" -s --blame --exclude vendor -p php; then
        printf "> Success. All of the %d generated patch files were valid.\n" "${expectedPatchCount}"
        return 0
    fi

    return 1
}

main "${@}"
