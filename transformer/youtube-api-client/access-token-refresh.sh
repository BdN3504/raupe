#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

[ ! -f "$scriptPath/$refreshToken" ] && echo "Retrieve the refresh token before trying to refresh the access token." && exit 1
refresh_token=$(cat "$scriptPath/$refreshToken")
responseFile=$tokenRefreshResponse

httpResponseCode=$(curl \
  -s \
  -w "%{http_code}" \
  --location \
  --request POST "$token_endpoint" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "client_id=$client_id" \
  --data-urlencode "client_secret=$client_secret" \
  --data-urlencode "refresh_token=$refresh_token" \
  --data-urlencode "grant_type=$grant_type_Refresh_token" \
  -o "$scriptPath/$responseFile")

if (($httpResponseCode > 200)); then
  echo "Refreshing access token failed."
  cat "$scriptPath/$responseFile"
  exit 1
fi
