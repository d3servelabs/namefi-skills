#!/usr/bin/env bash
# Usage: register-domain.sh <domain> [durationInYears]
# Registers a domain via Namefi API (async – poll check-order.sh for status).

set -euo pipefail

DOMAIN="${1:?Usage: $0 <domain> [durationInYears]}"
DURATION="${2:-1}"
BASE_URL="${NAMEFI_API_BASE_URL:-https://api.namefi.io/v-next}"

# Load .env if present and NAMEFI_API_KEY not already set
if [[ -z "${NAMEFI_API_KEY:-}" ]] && [[ -f ".env" ]]; then
  # shellcheck disable=SC1091
  source .env
fi

: "${NAMEFI_API_KEY:?NAMEFI_API_KEY must be set}"

curl --fail --silent --show-error \
  --request POST \
  --url "${BASE_URL}/orders/register-domain" \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  --header "x-api-key: ${NAMEFI_API_KEY}" \
  --data "{
    \"normalizedDomainName\": \"${DOMAIN}\",
    \"durationInYears\": ${DURATION}
  }" | tee /dev/stderr | jq -r '.id // empty'
