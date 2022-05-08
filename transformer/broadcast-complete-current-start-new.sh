#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
youtubeApiClientPath="$scriptPath/youtube-api-client"

echo "Checking authentication"
"$youtubeApiClientPath/authentication-check.sh"

numberOfDaysPassed=$("$youtubeApiClientPath/get-number-of-days-since-start-of-stream.sh")
"$youtubeApiClientPath/livebroadcasts-transition-complete.sh"
newTitle="Fancy broadcast title incorporating the number of days passed ($numberOfDaysPassed) since the start of the stream."
"$youtubeApiClientPath/client-variables.sh" -t "$newTitle" "$youtubeApiClientPath/client-variables.sh"
"$youtubeApiClientPath/livebroadcasts-insert.sh"
"$youtubeApiClientPath/livebroadcasts-bind.sh"
"$youtubeApiClientPath/livebroadcasts-transition-testing.sh"
"$scriptPath/broadcast-wait-for-test.sh"
"$youtubeApiClientPath/livebroadcasts-transition-live.sh"
"$youtubeApiClientPath/playlists-list-mine.sh"
. "$youtubeApiClientPath/client-variables.sh"
playlistId=$(jq -r ".items[] | select(.snippet.title = \"$playlistTitle\").id" "$youtubeApiClientPath/$playlistsListMineResponse")
[ -z "$playlistId" ] && "$youtubeApiClientPath/playlists-insert.sh" "$playlistTitle" "$playlistDescription" "$playlistDescriptionLanguage" "$playlistVisibility" && playlistId=$(jq -r ".id" "$youtubeApiClientPath/$playlistsInsertResponse")
videoId=$(jq -r ".id" "$youtubeApiClientPath/$broadcastsInsertResponse")
[ -z "$videoId" ] && echo "No livebroadcast has been inserted yet" && exit 1
"$youtubeApiClientPath/playlistItems-insert.sh" "$playlistId" "$videoId"
