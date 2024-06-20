#!/bin/bash -xeu

EMAIL="cf_email@example.com"
ZONE=your_zone_id  # https://dash.cloudflare.com/<account_id>/<zone>
APIKEY=your_api_key # https://dash.cloudflare.com/<account_id>/profile/api-tokens

RECORDID=$(curl -fso- -H "Authorization: Bearer ${APIKEY}" -H "Content-Type: application/json" "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${1}" | jq -crM '.result[].id')

jq -cMn --arg id "${RECORDID}" --arg name "${1}" --arg type "${2:-A}" --arg content $(curl -so- ipinfo.io/ip) '{"id":$id,"name":$name,"type":$type,"content":$content}' | \
	curl -fso- \
	--data @- \
        -H "Authorization: Bearer ${APIKEY}" \
        -H "Content-Type: application/json" \
        -X PUT \
	"https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORDID}" | \
		jq .