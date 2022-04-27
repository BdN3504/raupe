#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$broadcastsListInsertedResponse

insertedBroadcastId=$(jq -r .id "$scriptPath/$broadcastsInsertResponse")

httpResponseCode=$(curl \
  -w "%{http_code}" \
  -s \
  --location \
  --request GET \
  "$liveBroadcastsEndpoint?part=snippet%2CcontentDetails%2Cstatus&id=$insertedBroadcastId" \
  --header "Accept: application/json" \
  --header "Authorization: Bearer $access_token" \
  --compressed \
  -o "$scriptPath/$responseFile")

"$scriptPath/livebroadcasts-list-error-handling.sh" \
$httpResponseCode \
"$scriptPath/$responseFile" \
"$(realpath "$0")"
