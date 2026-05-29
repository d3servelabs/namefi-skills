#!/usr/bin/env bash
# Usage: dns-delete.sh <zoneName> <recordId> [recordId...]
# Deletes one or more DNS records by ID from a zone.
# Get record IDs first with dns-get.sh.

set -euo pipefail

ZONE="${1:?Usage: $0 <zoneName> <recordId> [recordId...]}"
shift
RECORD_IDS=("$@")

if [[ ${#RECORD_IDS[@]} -eq 0 ]]; then
  echo "Error: at least one recordId is required" >&2
  exit 1
fi

BASE_URL="https://backend.astra.namefi.io/v-next"

if [[ -z "${NAMEFI_API_KEY:-}" ]] && [[ -f ".env" ]]; then
  # shellcheck disable=SC1091
  source .env
fi

: "${NAMEFI_API_KEY:?NAMEFI_API_KEY must be set}"

# Build JSON array of record IDs
IDS_JSON=$(printf '"%s",' "${RECORD_IDS[@]}")
IDS_JSON="[${IDS_JSON%,}]"

curl --fail --silent --show-error \
  --request DELETE \
  --url "${BASE_URL}/dns/records/batch" \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  --header "x-api-key: ${NAMEFI_API_KEY}" \
  --data "{
    \"zoneName\": \"${ZONE}\",
    \"recordsIds\": ${IDS_JSON}
  }" | jq .
