#!/usr/bin/env bash
set -euxo pipefail

URL="$1"

HEADERS=$(curl --silent --head --location --max-time 10 "$URL")

echo "Checking security headers..."

# Format: "Header-Name:search-pattern"
REQUIRED_HEADERS=(
  "Content-Security-Policy:content-security-policy:"
  "X-Content-Type-Options:x-content-type-options: nosniff"
  "X-Frame-Options:x-frame-options:"
  "Strict-Transport-Security:strict-transport-security:"
  "Referrer-Policy:referrer-policy:"
  "Permissions-Policy:permissions-policy:"
)

FAILED=0

# Check each required header
for HEADER_CHECK in "${REQUIRED_HEADERS[@]}"; do
  # Split header name and search pattern
  HEADER_NAME="${HEADER_CHECK%%:*}"
  SEARCH_PATTERN="${HEADER_CHECK#*:}"

  if echo "$HEADERS" | grep -iq "$SEARCH_PATTERN"; then
    echo "$HEADER_NAME present"
  else
    echo "$HEADER_NAME missing"
    FAILED=1
  fi
done

exit $FAILED
