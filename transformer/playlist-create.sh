#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
youtubeApiClientPath="$scriptPath/youtube-api-client"

. "$youtubeApiClientPath/client-variables.sh"

echo "Checking authentication"
"$youtubeApiClientPath/authentication-check.sh"
"$youtubeApiClientPath/playlists-list-mine.sh"
playlistId=$(jq -r ".items[] | select(.snippet.title = \"$playlistTitle\").id" "$youtubeApiClientPath/$playlistsListMineResponse")
[ -z "$playlistId" ] && "$youtubeApiClientPath/playlists-insert.sh" "$playlistTitle" "$playlistDescription" "$playlistDescriptionLanguage" "$playlistVisibility" && playlistId=$(jq -r ".id" "$youtubeApiClientPath/$playlistsInsertResponse")
videoId=$(jq -r ".id" "$youtubeApiClientPath/$broadcastsInsertResponse")
[ -z "$videoId" ] && echo "No livebroadcast has been inserted yet" && exit 1
"$youtubeApiClientPath/playlistItems-insert.sh" "$playlistId" "$videoId"
