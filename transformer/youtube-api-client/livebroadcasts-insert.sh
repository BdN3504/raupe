#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$broadcastsInsertResponse

snippet="{'title':'$broadcastTitle','scheduledStartTime':'$(date -I'seconds')','description':'$broadcastDescription'}"
contentDetails="{'enableAutoStart':false,'monitorStream':{'enableMonitorStream':true}}"
status="{'privacyStatus':'unlisted','selfDeclaredMadeForKids':true}"

httpResponseCode=$(curl \
  -w "%{http_code}" \
  --request POST \
  "$liveBroadcastsEndpoint?part=snippet%2CcontentDetails%2Cstatus" \
  --header "Authorization: Bearer $access_token" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --data "{'snippet':$snippet,'contentDetails':$contentDetails,'status':$status}" \
  --compressed \
  -o "$scriptPath/$responseFile")

"$scriptPath/livebroadcasts-insert-error-handling.sh" \
$httpResponseCode \
"$scriptPath/$responseFile" \
"$(realpath "$0")"
