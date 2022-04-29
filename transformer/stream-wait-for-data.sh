#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
youtubeApiClientPath="$scriptPath/youtube-api-client"

. "$youtubeApiClientPath/client-variables.sh"

"$scriptPath/transformer-run.sh"

sleep 2

streamId=$(jq .id "$youtubeApiClientPath/$streamsInsertResponse")

"$youtubeApiClientPath/livestreams-list-inserted.sh"

streamStatus=$(jq -r ".items[] | select(.id == $streamId).status.streamStatus" "$youtubeApiClientPath/$streamsListInsertedResponse")
if [[ $streamStatus != "active" ]]; then
  echo "Stream with id $streamId has status \"$streamStatus\", restarting transformer."
  screen -S raupe -X quit
  "$scriptPath/transformer-run.sh"
  sleep 10
  "$scriptPath/$0"
  exit 0
fi
