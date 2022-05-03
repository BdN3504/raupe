#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
youtubeApiClientPath="$scriptPath/youtube-api-client"

. "$youtubeApiClientPath/client-variables.sh"
echo "Checking authentication"
"$youtubeApiClientPath/authentication-check.sh"

responseFile="$youtubeApiClientPath/$broadcastsListAllResponse"
echo "These are the youtube urls to all livebroadcasts of your channel:"

/bin/bash "$youtubeApiClientPath/livebroadcasts-list-all.sh" > /dev/null
jq -r --arg prefix "https://youtu.be/" '.items[] | $prefix + (.id + " - " + .snippet.title)' "$responseFile"
nextPageToken=$(jq -r .nextPageToken $responseFile)
until [ "$nextPageToken" == "null" ]
do
  /bin/bash "$youtubeApiClientPath/livebroadcasts-list-all.sh" "$nextPageToken" > /dev/null
  jq -r --arg prefix "https://youtu.be/" '.items[] | $prefix + (.id + " - " + .snippet.title)' "$responseFile"
  nextPageToken=$(jq -r .nextPageToken $responseFile)
done
