#!/usr/bin/env bash
# Usage: dns-update.sh <recordId> <zoneName> <type> <name> <rdata> [ttl]
# Updates an existing DNS record by ID.
# Get record IDs first with dns-get.sh.
#
# Example:
#   dns-update.sh abc123 example.com TXT @ "new-spf-value" 60

set -euo pipefail

RECORD_ID="${1:?Usage: $0 <recordId> <zoneName> <type> <name> <rdata> [ttl]}"
ZONE="${2:?Missing <zoneName>}"
TYPE="${3:?Missing <type>}"
NAME="${4:?Missing <name>}"
RDATA="${5:?Missing <rdata>}"
TTL="${6:-300}"
BASE_URL="https://backend.astra.namefi.io/v-next"

if [[ -z "${NAMEFI_API_KEY:-}" ]] && [[ -f ".env" ]]; then
  # shellcheck disable=SC1091
  source .env
fi

: "${NAMEFI_API_KEY:?NAMEFI_API_KEY must be set}"

curl --fail --silent --show-error \
  --request PUT \
  --url "${BASE_URL}/dns/records/${RECORD_ID}" \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  --header "x-api-key: ${NAMEFI_API_KEY}" \
  --data "{
    \"zoneName\": \"${ZONE}\",
    \"type\": \"${TYPE}\",
    \"name\": \"${NAME}\",
    \"rdata\": \"${RDATA}\",
    \"ttl\": ${TTL}
  }" | jq .
