#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
streamId=$(jq -r .id "$scriptPath/$streamsInsertResponse")
responseFile=$streamsListInsertedResponse

httpResponseCode=$(curl \
  -w "%{http_code}" \
  -s \
  --location \
  --request GET \
  "$liveStreamsEndpoint?id=$streamId" \
  --header "Accept: application/json" \
  --header "Authorization: Bearer $access_token" \
  --compressed \
  -o "$scriptPath/$responseFile")

"$scriptPath/livestreams-list-error-handling.sh" \
$httpResponseCode \
"$scriptPath/$responseFile" \
"$(realpath "$0")"

