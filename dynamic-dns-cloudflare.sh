#!/bin/bash -xeu

EMAIL=""
ZONE_NAME=""  # https://dash.cloudflare.com/<account_id>/<zone>
APIKEY=""     # https://dash.cloudflare.com/<account_id>/profile/api-tokens

# Get the zone ID
ZONE_ID=$(curl -s -H "Authorization: Bearer ${APIKEY}" -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/zones?name=${ZONE_NAME}" | grep -o '"id":"[^"]*"' | head -n 1 | cut -d':' -f2 | tr -d '"')

# Ensure ZONE_ID was found
if [ -z "$ZONE_ID" ]; then
  echo "Zone ID not found."
  exit 1
fi

# Get the current DNS record
CURRENT_RECORD=$(curl -s -H "Authorization: Bearer ${APIKEY}" -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${1}")

# Log the current record for debugging
echo "Current Record: $CURRENT_RECORD"

# Extract the record ID
RECORDID=$(echo "$CURRENT_RECORD" | grep -o '"id":"[^"]*"' | head -n 1 | cut -d':' -f2 | tr -d '"')

# Ensure RECORDID was found
if [ -z "$RECORDID" ]; then
  echo "Record ID not found."
  exit 1
fi

# Extract the current content IP
CURRENT_IP=$(echo "$CURRENT_RECORD" | grep -o '"content":"[^"]*"' | head -n 1 | cut -d':' -f2 | tr -d '"')

# Get the new IP
NEW_IP=$(curl -s ipinfo.io/ip)

# Log if IP has changed or not
if [ "$CURRENT_IP" == "$NEW_IP" ]; then
  echo "IP has not changed. Current IP: $CURRENT_IP"
else
  echo "IP has changed from $CURRENT_IP to $NEW_IP"

  # Set default type if not provided
  TYPE=${2:-A}

  # Create JSON data
  DATA=$(cat <<EOF
{
  "id": "${RECORDID}",
  "name": "${1}",
  "type": "${TYPE}",
  "content": "${NEW_IP}"
}
EOF
)

  # Make the PUT request
  RESPONSE=$(curl -s -f \
    --data "$DATA" \
    -H "Authorization: Bearer ${APIKEY}" \
    -H "Content-Type: application/json" \
    -X PUT \
    "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORDID}")

  # Print the response
  echo "$RESPONSE"
fi
