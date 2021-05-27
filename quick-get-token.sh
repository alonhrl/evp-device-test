#!/bin/bash
set -ue

. ./staging_credentials

URL='https://staging.ci.midocloud.net'

# Get tenant admin token from username & password:
get_tenant_token() {
    local full_url="${URL}/api/auth/login"
    local body='{"username": "'${TNT_ADM_EMAIL}'", "password": "'${TNTPWD}'"}'
    local cmd=("curl" "-X" "POST" "-s"
               "--header" "Accept: application/json"
               "--header" "Content-type: application/json"
               "-d" "${body}"
               "${full_url}")

    local out=$("${cmd[@]}")

    cut -d'"' -f 4 <<< "${out}"
}

export TNT_ADM_TOKEN=$(get_tenant_token)
echo "Token is:"
echo "$TNT_ADM_TOKEN"
