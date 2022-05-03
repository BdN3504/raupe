#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
httpResponseCode=$1
responseFile=$2
callingScript=$3

case $httpResponseCode in
  200)
    cat "$responseFile"
  ;;
  400)
    reason=$(jq -r .error.errors[0].reason "$responseFile")
    case $reason in
      "invalidValue")
        echo "The API does not support the ability to list the specified playlist. For example, you can't list your watch later playlist."
        exit 1
      ;;
    esac
  ;;
  403)
    reason=$(jq -r .error.errors[0].reason "$responseFile")
    case $reason in
      "channelClosed")
        echo "The channel specified in the channelId parameter has been closed."
        exit 1
      ;;
      "channelSuspended")
        echo "The channel specified in the channelId parameter has been suspended."
        exit 1
      ;;
      "playlistForbidden")
        echo "The playlist identified with the request's id parameter does not support the request or the request is not properly authorized."
        exit 1
      ;;
    esac
  ;;
  404)
    reason=$(jq -r .error.errors[0].reason "$responseFile")
    case $reason in
      "channelNotFound")
        echo "The channel specified in the channelId parameter cannot be found."
        exit 1
      ;;
      "playlistNotFound")
        echo "The playlist identified with the request's id parameter cannot be found."
        exit 1
      ;;
    esac
  ;;
  401)
    echo "Authentication failed"
    cat "$responseFile"
    sleep 1
    /bin/bash "$scriptPath/authentication-check.sh"
    /bin/bash "$callingScript"
    exit 1
  ;;
esac
