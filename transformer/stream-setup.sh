#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/transformer-variables.sh"

youtubeApiClientPath="$scriptPath/youtube-api-client"
. "$youtubeApiClientPath/client-variables.sh"

[ ! -f "$youtubeApiClientPath/$refreshToken" ] && echo "Refreshtoken has not been retrieved yet, assuming authentication was not done. Exiting." && exit 1

echo "Checking authentication"
$youtubeApiClientPath/authentication-check.sh
authenticationExitCode=$?

if [ $authenticationExitCode -ne 0 ]; then
  exit 1
fi

echo "Inserting livestream"
$youtubeApiClientPath/livestreams-insert.sh "$videoStreamFramerate" "$videoStreamResolution"
echo "Inserting livebroadcast"
$youtubeApiClientPath/livebroadcasts-insert.sh
echo "Starting transformer"
./stream-wait-for-data.sh
echo "Binding livebroadcast to livestream"
$youtubeApiClientPath/livebroadcasts-bind.sh
echo "Transitioning livebroadcast to testing"
./broadcast-wait-for-test.sh
read -re -p "Do you want to go live? Press enter to go live, ctrl-c to quit."
$youtubeApiClientPath/livebroadcasts-transition-live.sh
