#!/usr/bin/env bash

set -euo pipefail

trap script_exit_handler EXIT

# shellcheck disable=SC2329
function script_exit_handler() {
    local last_exit_code=$?

    # Clean up temporary secrets
    local secrets_dir="${SCRIPT_DIR}/.secrets"
    if [[ -d ${secrets_dir} ]]; then
        printf "> Cleaning up temporary secrets...\n"
        rm -rf "${secrets_dir}"
    fi

    if [[ ${last_exit_code} == 0 ]]; then
        printf "> Execution completed successfully\n"
        exit "${last_exit_code}"
    fi

    printf "> Execution failed\n"
    exit "${last_exit_code}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HCL_FILE="$(cd "${SCRIPT_DIR}/../.." && pwd)/docker-bake-common.hcl"

function ensure_secrets() {
    printf "> Ensuring secrets are generated in temporary location...\n"
    local repo_root
    repo_root=$(cd "${SCRIPT_DIR}/../../.." && pwd)

    local secrets_dir="${SCRIPT_DIR}/.secrets"
    mkdir -p "${secrets_dir}"

    # Export git mock function and mock repo root
    export MOCK_REPO_ROOT="${SCRIPT_DIR}"

    # shellcheck disable=SC2329
    function git() {
        if [[ "$*" == "rev-parse --show-toplevel" ]]; then
            echo "${MOCK_REPO_ROOT}"
        else
            command git "$@"
        fi
    }
    export -f git

    # Generate database passwords in the temporary directory
    "${repo_root}/src/init-utils/init-wp"

    # Clean up any "data" directories
    if [[ -d "${SCRIPT_DIR}/data" ]]; then
        rm -rf "${SCRIPT_DIR}/data"
    fi

    # Clean up git mock
    unset -f git
    unset MOCK_REPO_ROOT

    # Generate WP salts inside the temporary directory
    DOCKER_SECRETS_DIR="${secrets_dir}" "${repo_root}/src/wp-utils/wp-generate-salts"

    # Generate wordpress_init_admin_password inside the temporary directory
    local admin_passwd_file="${secrets_dir}/wordpress_init_admin_password"
    if [[ ! -f ${admin_passwd_file} || ! -s ${admin_passwd_file} ]]; then
        printf "> Generating wordpress_init_admin_password...\n"
        "${repo_root}/src/utils/random-string" 32 >"${admin_passwd_file}"
    fi
}

function extract_versions_from_hcl() {
    local hcl_file=${1:?HCL file path required}

    gawk '
        /"([0-9]+\.[0-9]+\.[0-9]+)" *= *{ *patch_version *= *"([0-9]+\.[0-9]+\.[0-9]+)"/ {
            if (match($0, /"([0-9]+\.[0-9]+\.[0-9]+)"/, arr)) {
                print arr[1];
            }
        }
    ' "${hcl_file}"
}

function test_wp_version() {
    local container_id=${1:?}
    local expected_version=${2:?}

    printf "> Verifying running WordPress version (expected: %s)...\n" "${expected_version}"

    local running_version
    running_version=$(docker exec "${container_id}" wp core version --allow-root 2>/dev/null | tr -d '\r\n' || printf "")

    printf "  Detected WordPress Version: %s\n" "${running_version}"

    if [[ ${running_version} != "${expected_version}" ]]; then
        printf "  Version check: FAILED! Expected '%s', but detected '%s'\n" "${expected_version}" "${running_version}"
        return 1
    fi

    printf "  Version check: SUCCESS!\n"
    return 0
}

function test_wp_curl() {
    printf "> Running verification HTTP curl requests...\n"

    # Homepage check
    local home_code
    home_code=$(curl -sS -o /dev/null -w "%{http_code}" http://localhost:8080/ || printf "000")

    printf "  Homepage HTTP Status: %s\n" "${home_code}"

    # wp-admin redirect check (following redirects)
    local admin_code
    admin_code=$(curl -sS -L -o /dev/null -w "%{http_code}" http://localhost:8080/wp-admin/ || printf "000")
    printf "  wp-admin HTTP Status (following redirects): %s\n" "${admin_code}"

    # Fetch index contents and check for errors
    local homepage_body
    homepage_body=$(curl -sS -L http://localhost:8080/ || printf "")

    if [[ ${home_code} != "200" ]]; then
        printf "  Curl check: FAILED! Homepage returned HTTP code %s. 200 was expected\n" "${home_code}"
        return 1
    fi

    if [[ ${admin_code} != "200" ]]; then
        printf "  Curl check: FAILED! wp-admin request failed with HTTP code %s\n" "${admin_code}"
        return 1
    fi

    if printf "%s\n" "${homepage_body}" | grep -qiE "fatal error|parse error|database error|warning:"; then
        printf "  Curl check: FAILED! Detected PHP/database error in homepage HTML body\n"
        printf -- "--- HTML Page Body snippet ---\n"
        printf "%s\n" "${homepage_body}" | head -n 40
        printf -- "------------------------------\n"
        return 1
    fi

    printf "  Curl check: SUCCESS!\n"
    return 0
}

function test_wp_login() {
    local cookie_jar=${1:?}
    local admin_password=${2:?}

    printf "> Attempting login to wp-admin...\n"

    # Step A: Get test cookie
    curl -sS -c "${cookie_jar}" http://localhost:8080/wp-login.php >/dev/null

    # Step B: Submit login form
    curl -sS -L \
        -c "${cookie_jar}" \
        -b "${cookie_jar}" \
        -d "log=admin" \
        --data-urlencode "pwd=${admin_password}" \
        -d "wp-submit=Log In" \
        -d "testcookie=1" \
        -d "redirect_to=http://localhost:8080/wp-admin/" \
        -o /dev/null \
        http://localhost:8080/wp-login.php

    # Step C: Retrieve dashboard using cookies
    local dashboard_body
    dashboard_body=$(curl -sS -L \
        -b "${cookie_jar}" \
        http://localhost:8080/wp-admin/ || printf "")

    # Step D: Assert login success
    if [[ ${dashboard_body} == *"wp-admin-bar"* || ${dashboard_body} == *"wpadminbar"* || ${dashboard_body} == *"Dashboard"* || ${dashboard_body} == *"dashboard"* || ${dashboard_body} == *"wp-toolbar"* ]]; then
        printf "  Login check: SUCCESS! Successfully logged in to wp-admin.\n"
        return 0
    else
        printf "  Login check: FAILED!\n"
        printf -- "--- wp-admin response snippet ---\n"
        printf "%s\n" "${dashboard_body}" | head -n 40
        printf -- "---------------------------------\n"
        return 1
    fi
}

function test_wp_update_disabled() {
    local cookie_jar=${1:?}

    printf "> Attempting core update check...\n"

    local update_response
    update_response=$(curl -sS -L \
        -b "${cookie_jar}" \
        "http://localhost:8080/wp-admin/update-core.php?action=do-core-upgrade" || printf "")

    if [[ ${update_response} == *"WordPress-Core-Updates"* ]]; then
        printf "  Update disable check: SUCCESS! Core updates are successfully blocked.\n"
        return 0
    else
        printf "  Update disable check: FAILED!\n"
        printf -- "--- update response snippet ---\n"
        printf "%s\n" "${update_response}" | head -n 40
        printf -- "--------------------------------\n"
        return 1
    fi
}

function run_test_for_version() {
    local version=${1:?Version is required}
    local image="ghcr.io/n0rthernl1ghts/wordpress:${version}"
    local passed=true
    local fail_reason=""

    printf "================================================================================\n"
    printf "  TESTING WORDPRESS VERSION: %s\n" "${version}"
    printf "  Image: %s\n" "${image}"
    printf "================================================================================\n"

    printf "> Pulling image...\n"
    if ! docker pull "${image}"; then
        printf "Error: Failed to pull image %s\n" "${image}"
        return 1
    fi

    # Ensure clean
    docker compose -f "${SCRIPT_DIR}/compose.yaml" down -v >/dev/null 2>&1 || true

    printf "> Starting containers...\n"
    export WORDPRESS_TEST_IMAGE=${image}
    if ! docker compose -f "${SCRIPT_DIR}/compose.yaml" up -d --force-recreate; then
        printf "Error: Failed to start docker-compose services\n"
        return 1
    fi

    # Wait for WordPress to become healthy
    printf "> Waiting for WordPress container to become healthy (checking every 2 seconds)...\n"
    local max_attempts=60
    local attempt=0
    local healthy=false
    local container_id=""

    # Retrieve container ID
    for ((i = 1; i <= 10; i++)); do
        container_id=$(docker compose -f "${SCRIPT_DIR}/compose.yaml" ps -q wordpress 2>/dev/null || printf "")
        if [[ -n ${container_id} ]]; then
            break
        fi
        sleep 1
    done

    if [[ -z ${container_id} ]]; then
        printf "Error: WordPress container did not start.\n"
        docker compose -f "${SCRIPT_DIR}/compose.yaml" logs
        docker compose -f "${SCRIPT_DIR}/compose.yaml" down -v >/dev/null 2>&1 || true
        return 1
    fi

    while [[ ${attempt} -lt ${max_attempts} ]]; do
        local status
        status=$(docker inspect --format='{{.State.Health.Status}}' "${container_id}" 2>/dev/null || printf "starting")

        if [[ ${status} == "healthy" ]]; then
            healthy=true
            printf "WordPress container is healthy!\n"
            break
        elif [[ ${status} == "unhealthy" ]]; then
            printf "WordPress container reported UNHEALTHY!\n"
            break
        fi

        sleep 2
        attempt=$((attempt + 1))
    done

    if [[ ${healthy} == "false" ]]; then
        passed=false
        fail_reason="Container health check timed out or reported unhealthy"
        printf "Error: Container health verification failed.\n"
    else
        local expected_version
        expected_version=$(printf "%s" "${version}" | sed --expression='s/\.0$//g')

        local cookie_jar
        cookie_jar=$(mktemp)

        local admin_password
        admin_password=$(cat "${SCRIPT_DIR}/.secrets/wordpress_init_admin_password" | tr -d '\r\n')

        # Run test pipeline sequentially
        if ! test_wp_version "${container_id}" "${expected_version}"; then
            passed=false
            fail_reason="WordPress version mismatch"
        elif ! test_wp_curl; then
            passed=false
            fail_reason="HTTP curl health checks failed"
        elif ! test_wp_login "${cookie_jar}" "${admin_password}"; then
            passed=false
            fail_reason="Failed to log in to wp-admin"
        elif ! test_wp_update_disabled "${cookie_jar}"; then
            passed=false
            fail_reason="Core updates are not blocked"
        fi

        # Always clean up cookie jar
        rm -f "${cookie_jar}"
    fi

    if [[ ${passed} == "false" ]]; then
        printf "Error: Verification failed. Printing container logs...\n"
        printf -- "--- wordpress logs ---\n"

        docker compose -f "${SCRIPT_DIR}/compose.yaml" logs wordpress --tail=100
        printf -- "--- database logs ---\n"

        docker compose -f "${SCRIPT_DIR}/compose.yaml" logs database --tail=100
        printf -- "----------------------\n"
    fi

    # Tear down containers and delete volumes
    printf "> Tearing down containers and deleting volumes...\n"
    docker compose -f "${SCRIPT_DIR}/compose.yaml" down -v >/dev/null 2>&1 || true

    if [[ ${passed} == "true" ]]; then
        printf "SUCCESS: Version %s is fully functional!\n" "${version}"
        return 0
    else
        printf "FAIL: Version %s failed. Reason: %s\n" "${version}" "${fail_reason}"
        return 1
    fi
}

main() {
    ensure_secrets

    # Determine which versions to test
    local -a test_versions=()

    if [[ ${#} -gt 0 ]]; then
        test_versions=("${@}")
    else
        # Extract versions from bake common HCL file
        printf "No versions specified. Extracting versions from HCL config...\n"
        if [[ ! -f ${HCL_FILE} ]]; then
            printf "Error: HCL file not found at %s\n" "${HCL_FILE}"
            exit 1
        fi
        mapfile -t test_versions < <(extract_versions_from_hcl "${HCL_FILE}")
    fi

    printf "Versions to test: %s\n" "${test_versions[*]}"
    printf "\n"

    local -a passed_versions=()
    local -a failed_versions=()

    for version in "${test_versions[@]}"; do
        if run_test_for_version "${version}"; then
            passed_versions+=("${version}")
        else
            failed_versions+=("${version}")
        fi
        printf "\n"
    done

    printf "================================================================================\n"
    printf "  TEST SUMMARY\n"
    printf "================================================================================\n"
    printf "  Total versions tested: %d\n" $((${#passed_versions[@]} + ${#failed_versions[@]}))
    printf "  PASSED: [%s]\n" "${passed_versions[*]:-None}"
    printf "  FAILED: [%s]\n" "${failed_versions[*]:-None}"
    printf "================================================================================\n"

    if [[ ${#failed_versions[@]} -gt 0 ]]; then
        exit 1
    fi
    exit 0
}

main "${@}"
