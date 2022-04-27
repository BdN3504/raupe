#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
youtubeApiClientPath="$scriptPath/youtube-api-client"

. "$youtubeApiClientPath/client-variables.sh"
echo "Checking authentication"
"$youtubeApiClientPath/authentication-check.sh"

broadCastId=$(jq .id "$youtubeApiClientPath/$broadcastsInsertResponse")
"$youtubeApiClientPath/livebroadcasts-list-inserted.sh"
broadCastStatus=$(jq -r ".items[] | select(.id == $broadCastId).status.lifeCycleStatus" "$youtubeApiClientPath/$broadcastsListInsertedResponse")

if [[ $broadCastStatus != "testing" ]]; then
  echo "Broadcast with id $broadCastId is not testing yet. Status is \"$broadCastStatus\""
  ./youtube-api-client/livebroadcasts-transition-testing.sh
  sleep 10
  ./"$0"
  exit 0
fi
