#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$broadcastsTransitionCompleteResponse

broadcastId=$(jq -r .id "$scriptPath/$broadcastsInsertResponse")

httpResponseCode=$(curl \
  -w "%{http_code}" \
  -s \
  --request POST \
  "$liveBroadcastsEndpoint/transition?broadcastStatus=complete&id=$broadcastId&part=id%2Cstatus" \
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
  recordingId=$(jq -r .id "$scriptPath/$responseFile")
  echo "Watch the recording here:"
  echo "https://youtu.be/$recordingId"
fi
