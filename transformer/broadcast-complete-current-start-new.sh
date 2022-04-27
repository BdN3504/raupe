#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
youtubeApiClientPath="$scriptPath/youtube-api-client"
numberOfDaysPassed=$("$youtubeApiClientPath/get-number-of-days-since-start-of-stream.sh")

. "$youtubeApiClientPath/client-variables.sh"
echo "Checking authentication"
"$youtubeApiClientPath/authentication-check.sh"
"$youtubeApiClientPath/livebroadcasts-transition-complete.sh"
title="Caterpillar live broadcast - Vanessa Cardui - day $numberOfDaysPassed"
"$youtubeApiClientPath/client-variables.sh" -t $title
"$youtubeApiClientPath/livebroadcasts-insert.sh"
"$youtubeApiClientPath/livebroadcasts-bind.sh"
"$youtubeApiClientPath/livebroadcasts-transition-testing.sh"
"$youtubeApiClientPath/livebroadcasts-transition-live.sh"
