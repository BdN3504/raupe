#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$streamsInsertResponse

case $1 in
  "30")
    videoStreamFramerate="30fps"
  ;;
  "60")
    videoStreamFramerate="60fps"
  ;;
  *)
    videoStreamFramerate="variable"
  ;;
esac

case $2 in
  "426x240")
    videoStreamResolution="240p"
  ;;
  "640x360")
    videoStreamResolution="360p"
  ;;
  "854x480")
    videoStreamResolution="480p"
  ;;
  "1280x720")
    videoStreamResolution="720p"
  ;;
  "1920x1080")
    videoStreamResolution="1080p"
  ;;
  "2560x1440")
    videoStreamResolution="1440p"
  ;;
  "3840x2160")
    videoStreamResolution="2160p"
  ;;
  *)
    videoStreamResolution="variable"
  ;;
esac

content=$(cat << EOF
{
  "snippet": {
    "title": "$streamTitle",
    "description": "$streamDescription"
  },
  "cdn": {
    "frameRate": "$videoStreamFramerate",
    "ingestionType": "rtmp",
    "resolution": "$videoStreamResolution"
  },
  "contentDetails": {
    "isReusable": true
  }
}
EOF
)

httpResponseCode=$(curl \
  -w "%{http_code}" \
  --request POST \
  "$liveStreamsEndpoint?part=snippet%2Ccdn%2CcontentDetails" \
  --header "Authorization: Bearer $access_token" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --data "$content" \
  --compressed \
  -o "$scriptPath/$responseFile")

"$scriptPath/livestreams-insert-error-handling.sh" \
$httpResponseCode \
"$scriptPath/$responseFile" \
"$(realpath "$0")"
