#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$playlistsInsertResponse

query="part=snippet%2Cstatus"

if (($# < 4)); then
  echo "Provide 4 arguments:"
  echo "1. : Playlist title"
  echo "2. : Playlist description"
  echo "3. : 2 letter language code of the playlist title and description"
  echo "4. : Playlist visibilty: 'private', 'public' or 'unlisted'"
  exit 1
fi
snippet="{'title':'$1','description':'$2','defaultLanguage':'$3'}"
status="{'privacyStatus':'$4'}"

httpResponseCode=$(curl \
  -s \
  -w "%{http_code}" \
  --location \
  --request POST \
  "$playlistsEndpoint?$query" \
  --header "Accept: application/json" \
  --header "Authorization: Bearer $access_token" \
  --header 'Content-Type: application/json' \
  --data "{'snippet':$snippet,'status':$status}" \
  --compressed \
  -o "$scriptPath/$responseFile")

"$scriptPath/playlists-insert-error-handling.sh" \
$httpResponseCode \
"$scriptPath/$responseFile" \
"$(realpath "$0")"

