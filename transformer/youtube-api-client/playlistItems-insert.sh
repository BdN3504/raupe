#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")

if (($# < 2)); then
  echo "Provide 2 arguments:"
  echo "1. : Id of the playlist to add content to."
  echo "2. : Id of the video to add to the playlist."
fi

playlistId=$1
videoId=$2

responseFile=$playlistItemsInsertResponse

query="part=snippet"

content=$(cat << EOF
{
  "snippet": {
    "playlistId": "$playlistId",
    "position": 0,
    "resourceId": {
      "kind": "youtube#video",
      "videoId": "$videoId"
    }
  }
}
EOF
)

httpResponseCode=$(curl \
  -s \
  -w "%{http_code}" \
  --location \
  --request POST \
  "$playlistItemsEndpoint?$query" \
  --header "Accept: application/json" \
  --header "Authorization: Bearer $access_token" \
  --header 'Content-Type: application/json' \
  --data "$content" \
  --compressed \
  -o "$scriptPath/$responseFile")

"$scriptPath/playlistItems-insert-error-handling.sh" \
$httpResponseCode \
"$scriptPath/$responseFile" \
"$(realpath "$0")"

