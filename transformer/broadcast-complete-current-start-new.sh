#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
youtubeApiClientPath="$scriptPath/youtube-api-client"

echo "Checking authentication"
"$youtubeApiClientPath/authentication-check.sh"

numberOfDaysPassed=$("$youtubeApiClientPath/get-number-of-days-since-start-of-stream.sh")
"$youtubeApiClientPath/livebroadcasts-transition-complete.sh"
newTitle="Caterpillar live broadcast - Vanessa Cardui - day $numberOfDaysPassed"
"$youtubeApiClientPath/client-variables.sh" -t "$newTitle" "$youtubeApiClientPath/client-variables.sh"
"$youtubeApiClientPath/livebroadcasts-insert.sh"
"$youtubeApiClientPath/livebroadcasts-bind.sh"
"$youtubeApiClientPath/livebroadcasts-transition-testing.sh"
sleep 10
"$youtubeApiClientPath/livebroadcasts-transition-live.sh"
