#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
httpResponseCode=$1
responseFile=$2
callingScript=$3

case $httpResponseCode in
  401)
    echo "http code: $httpResponseCode"
    cat "$scriptPath/$responseFile"
    sleep 1
    /bin/bash "$scriptPath/authentication-check.sh"
    /bin/bash "$callingScript"
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
    streamTitle=$(jq -r .snippet.title "$scriptPath/$responseFile")
    echo "Successfully inserted \"$streamTitle\"."
    responseStreamUrl=$(jq -r .cdn.ingestionInfo.ingestionAddress  "$scriptPath/$responseFile")
    responseStreamName=$(jq -r .cdn.ingestionInfo.streamName  "$scriptPath/$responseFile")
    echo "IngestionUrl: $responseStreamUrl/$responseStreamName"
    exit 0
  ;;
esac
