#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$streamsInsertResponse

snippet="{'title':'$streamTitle','description':'$streamDescription'}"
cdn="{'frameRate':'30fps','ingestionType':'rtmp','resolution':'1080p'}"
contentDetails="{'isReusable':true}"

httpResponseCode=$(curl \
  -w "%{http_code}" \
  --request POST \
  "$liveStreamsEndpoint?part=snippet%2Ccdn%2CcontentDetails" \
  --header "Authorization: Bearer $access_token" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --data "{'snippet':$snippet,'cdn':$cdn,'contentDetails':$contentDetails}" \
  --compressed \
  -o "$scriptPath/$responseFile")

case $httpResponseCode in
  401)
    echo "http code: $httpResponseCode"
    cat "$scriptPath/$responseFile"
    sleep 1
    "$scriptPath/authentication-check.sh"
    "$(realpath "$0")"
    exit 1
  ;;

  400)
    reason=$(jq -r .error.errors[0].reason  "$scriptPath/$responseFile")
    case $reason in
      "invalidDescription")
        echo "The snippet.description property's value in the liveStream resource can have up to 10000 characters."
        exit 1
      ;;
      "invalidFormat")
        echo "The cdn.format property's value in the liveStream resource is invalid."
        exit 1
      ;;
      "invalidFrameRate")
        echo "The cdn.frameRate property's value in the liveStream resource is invalid."
        exit 1
      ;;
      "invalidIngestionType")
        echo "The cdn.ingestionType property's value in the liveStream resource is invalid."
        exit 1
      ;;
      "invalidResolution")
        echo "The cdn.resolution property's value in the liveStream resource is invalid."
        exit 1
      ;;
      "invalidTitle")
        echo "The snippet.title property's value in the liveStream resource must be between 1 and 128 characters long."
        exit 1
      ;;
      "cdnRequired")
        echo "The liveStream resource must contain the cdn object."
        exit 1
      ;;
      "frameRateRequired")
        echo "The API returns this error if you specify a value for the cdn.resolution property but not for the cdn.frameRate property."
        exit 1
      ;;
      "ingestionTypeRequired")
        echo "The liveStream resource must specify a value for the cdn.ingestionType property."
        exit 1
      ;;
      "resolutionRequired")
        echo "The API returns this error if you specify a value for the cdn.frameRate property but not for the cdn.resolution property."
        exit 1
      ;;
      "titleRequired")
        echo "The liveStream resource must specify a value for the snippet.title property."
        exit 1
      ;;
    esac
  ;;

  200)
    echo "Successfully inserted $streamTitle."
    responseStreamUrl=$(jq -r .cdn.ingestionInfo.ingestionAddress  "$scriptPath/$responseFile")
    responseStreamName=$(jq -r .cdn.ingestionInfo.streamName  "$scriptPath/$responseFile")
    echo "IngestionUrl: $responseStreamUrl/$responseStreamName"
    exit 0
  ;;
esac
