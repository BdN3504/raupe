#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
youtubeApiClientPath="$scriptPath/youtube-api-client"

. "$youtubeApiClientPath/client-variables.sh"

echo "Checking authentication"
"$youtubeApiClientPath/authentication-check.sh"
"$youtubeApiClientPath/playlists-list-mine.sh"
