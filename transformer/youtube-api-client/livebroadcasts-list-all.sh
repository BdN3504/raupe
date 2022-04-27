#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$broadcastsListAllResponse

httpResponseCode=$(curl \
  -s \
  -w "%{http_code}" \
  --location \
  --request GET \
  "$liveBroadcastsEndpoint?broadcastStatus=all" \
  --header "Accept: application/json" \
  --header "Authorization: Bearer $access_token" \
  -o "$scriptPath/$responseFile")

"$scriptPath/livebroadcasts-list-error-handling.sh" \
$httpResponseCode \
"$scriptPath/$responseFile" \
"$(realpath "$0")"
