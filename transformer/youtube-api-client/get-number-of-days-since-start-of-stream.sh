#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))

. "$scriptPath/client-variables.sh"

streamId=$(jq .id $scriptPath/$streamsInsertResponse)

todaysDate=$(date +"%Y-%m-%d")

streamStartedDateTime=$($scriptPath/livestreams-list-inserted.sh | jq -r ".items[] | select(.id == $streamId).snippet.publishedAt")

streamStartedDate=$(date +"%Y-%m-%d" -ud "$streamStartedDateTime")

echo $(( ($(date +%s -ud "$todaysDate") - $(date +%s -ud "$streamStartedDate")) / 3600 / 24 ))
