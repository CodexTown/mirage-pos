#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 'AUTHORIZATION_CODE_FROM_BROWSER_URL'" >&2
  exit 2
fi

: "${GOOGLE_CLIENT_ID:?GOOGLE_CLIENT_ID is required}"
: "${GOOGLE_CLIENT_SECRET:?GOOGLE_CLIENT_SECRET is required}"

AUTH_CODE="$1"

curl -sS -X POST https://oauth2.googleapis.com/token \
  -d "client_id=${GOOGLE_CLIENT_ID}" \
  -d "client_secret=${GOOGLE_CLIENT_SECRET}" \
  -d "code=${AUTH_CODE}" \
  -d "grant_type=authorization_code" \
  -d "redirect_uri=http://localhost:1"
