#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$broadcastsTransitionLiveResponse

broadcastId=$(jq -r .id "$scriptPath/$broadcastsInsertResponse")

httpResponseCode=$(curl \
  -w "%{http_code}" \
  -s \
  --request POST \
  "$liveBroadcastsEndpoint/transition?broadcastStatus=live&id=$broadcastId&part=id%2Cstatus" \
  --header "Authorization: Bearer $access_token" \
  --header "Accept: application/json" \
  --compressed \
  -o "$scriptPath/$responseFile")

"$scriptPath/livebroadcasts-transition-error-handling.sh" \
$httpResponseCode \
"$scriptPath/$responseFile" \
"$(realpath "$0")"

transtionExitCode=$?

if [ $transtionExitCode -eq 0 ]; then
  transitionedBroadcastId=$(jq -r .id "$scriptPath/$responseFile")
  echo "Watch the stream here:"
  echo "https://youtu.be/$transitionedBroadcastId"
fi
