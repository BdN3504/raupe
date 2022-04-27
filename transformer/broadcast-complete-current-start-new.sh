#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
youtubeApiClientPath="$scriptPath/youtube-api-client"

. "$youtubeApiClientPath/client-variables.sh"
echo "Checking authentication"
"$youtubeApiClientPath/authentication-check.sh"

"$youtubeApiClientPath/livebroadcasts-transition-complete.sh"
"$youtubeApiClientPath/livebroadcasts-insert.sh"
"$youtubeApiClientPath/livebroadcasts-bind.sh"
"$youtubeApiClientPath/livebroadcasts-transition-testing.sh"
"$youtubeApiClientPath/livebroadcasts-transition-live.sh"
