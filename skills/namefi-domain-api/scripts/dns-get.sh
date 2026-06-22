#!/usr/bin/env bash
# Usage: dns-get.sh <zoneName>
# Lists all DNS records for a zone.

set -euo pipefail

ZONE="${1:?Usage: $0 <zoneName>}"
BASE_URL="${NAMEFI_API_BASE_URL:-https://api.namefi.io/v-next}"

if [[ -z "${NAMEFI_API_KEY:-}" ]] && [[ -f ".env" ]]; then
  # shellcheck disable=SC1091
  source .env
fi

: "${NAMEFI_API_KEY:?NAMEFI_API_KEY must be set}"

curl --fail --silent --show-error \
  --url "${BASE_URL}/dns/records?zoneName=${ZONE}" \
  --header "Accept: application/json" \
  --header "x-api-key: ${NAMEFI_API_KEY}" | jq .
