#!/usr/bin/env bash
# Usage: check-order.sh <orderId> [--poll]
# Checks the status of a Namefi order.
# Pass --poll to keep polling every 5s until a terminal status is reached.

set -euo pipefail

ORDER_ID="${1:?Usage: $0 <orderId> [--poll]}"
POLL="${2:-}"
BASE_URL="${NAMEFI_API_BASE_URL:-https://api.namefi.io/v-next}"
TERMINAL_STATUSES="SUCCEEDED FAILED CANCELLED PARTIALLY_COMPLETED"

if [[ -z "${NAMEFI_API_KEY:-}" ]] && [[ -f ".env" ]]; then
  # shellcheck disable=SC1091
  source .env
fi

: "${NAMEFI_API_KEY:?NAMEFI_API_KEY must be set}"

get_status() {
  curl --fail --silent --show-error \
    --url "${BASE_URL}/orders/${ORDER_ID}" \
    --header "Accept: application/json" \
    --header "x-api-key: ${NAMEFI_API_KEY}"
}

is_terminal() {
  local status="$1"
  for s in $TERMINAL_STATUSES; do
    [[ "$s" == "$status" ]] && return 0
  done
  return 1
}

while true; do
  response=$(get_status)
  status=$(echo "$response" | jq -r '.order.status // .status // "UNKNOWN"')
  echo "Order ${ORDER_ID}: ${status}"

  if [[ "$POLL" == "--poll" ]]; then
    if is_terminal "$status"; then
      echo "$response" | jq .
      break
    fi
    sleep 5
  else
    echo "$response" | jq .
    break
  fi
done
