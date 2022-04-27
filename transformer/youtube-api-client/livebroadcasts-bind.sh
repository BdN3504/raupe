#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$broadcastsBindResponse

broadcastId=$(jq -r .id "$scriptPath/$broadcastsInsertResponse")
stream_id=$(jq -r .id "$scriptPath/$streamsInsertResponse")

httpResponseCode=$(curl \
  -s \
  -w "%{http_code}" \
  --request POST \
  "$liveBroadcastsEndpoint/bind?id=$broadcastId&part=snippet&streamId=$stream_id" \
  --header "Authorization: Bearer $access_token" \
  --header "Accept: application/json" \
  --compressed \
  -o "$scriptPath/$responseFile")

"$scriptPath/livebroadcasts-bind-error-handling.sh" \
$httpResponseCode \
"$scriptPath/$responseFile" \
"$(realpath "$0")"
