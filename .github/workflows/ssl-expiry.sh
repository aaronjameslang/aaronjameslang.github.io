#!/usr/bin/env bash
set -euo pipefail

URL="$1"

# Extract domain from URL (remove https:// and everything after /)
DOMAIN=$(echo "$URL" | sed -e 's|^https://||' -e 's|/.*||')

# Retrieve certificate expiry date using OpenSSL
EXPIRY_DATE=$(
  echo | \
  openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" \
    2>/dev/null | \
  openssl x509 -noout -enddate | \
  cut -d= -f2
)

# Convert expiry date to epoch time (handle both GNU and BSD date)
EXPIRY_EPOCH=$(
  date -d "$EXPIRY_DATE" +%s 2>/dev/null || \
  date -j -f "%b %d %T %Y %Z" "$EXPIRY_DATE" +%s
)

# Get current time in epoch format
CURRENT_EPOCH=$(date +%s)

# Calculate days until certificate expires
DAYS_UNTIL_EXPIRY=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))

echo "Certificate expires: $EXPIRY_DATE"
echo "Days until expiry: $DAYS_UNTIL_EXPIRY"

# Fail if certificate expires in less than 30 days
if [ $DAYS_UNTIL_EXPIRY -lt 30 ]; then
  echo "Certificate expires in less than 30 days"
  exit 1
fi
