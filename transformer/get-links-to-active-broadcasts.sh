#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
youtubeApiClientPath="$scriptPath/youtube-api-client"

. "$youtubeApiClientPath/client-variables.sh"
echo "Checking authentication"
"$youtubeApiClientPath/authentication-check.sh"

responseFile="$youtubeApiClientPath/$broadcastsListActiveResponse"
echo "These are the youtube urls to the currently active livebroadcasts of your channel:"
/bin/bash "$youtubeApiClientPath/livebroadcasts-list-active.sh" | jq -r --arg prefix "https://youtu.be/" '.items[] | $prefix + (.id + " - " + .snippet.title)'
