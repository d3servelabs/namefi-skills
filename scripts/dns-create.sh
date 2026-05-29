#!/usr/bin/env bash
# Usage: dns-create.sh <zoneName> <type> <name> <rdata> [ttl]
# Creates a DNS record in a zone.
#
# Examples:
#   dns-create.sh example.com A @ 203.0.113.10 300
#   dns-create.sh example.com TXT @ "v=spf1 include:_spf.google.com ~all" 300
#   dns-create.sh example.com CNAME www example.com. 300

set -euo pipefail

ZONE="${1:?Usage: $0 <zoneName> <type> <name> <rdata> [ttl]}"
TYPE="${2:?Missing <type> (e.g. A, CNAME, TXT, MX)}"
NAME="${3:?Missing <name> (use @ for apex)}"
RDATA="${4:?Missing <rdata>}"
TTL="${5:-300}"
BASE_URL="https://backend.astra.namefi.io/v-next"

if [[ -z "${NAMEFI_API_KEY:-}" ]] && [[ -f ".env" ]]; then
  # shellcheck disable=SC1091
  source .env
fi

: "${NAMEFI_API_KEY:?NAMEFI_API_KEY must be set}"

curl --fail --silent --show-error \
  --request POST \
  --url "${BASE_URL}/dns/records/batch" \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  --header "x-api-key: ${NAMEFI_API_KEY}" \
  --data "{
    \"zoneName\": \"${ZONE}\",
    \"records\": [
      {
        \"type\": \"${TYPE}\",
        \"name\": \"${NAME}\",
        \"rdata\": \"${RDATA}\",
        \"ttl\": ${TTL}
      }
    ]
  }" | jq .
