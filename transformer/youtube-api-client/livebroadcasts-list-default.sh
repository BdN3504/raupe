#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$broadcastsListDefaultResponse

httpResponseCode=$(curl \
  -s \
  -w "%{http_code}" \
  --location \
  --request GET \
  "$liveBroadcastsEndpoint?broadcastStatus=all&broadcastType=persistent" \
  --header "Accept: application/json" \
  --header "Authorization: Bearer $access_token" \
  -o "$scriptPath/$responseFile")

"$scriptPath/livestreams-list-error-handling.sh" \
$httpResponseCode \
"$scriptPath/$responseFile" \
"$(realpath "$0")"
