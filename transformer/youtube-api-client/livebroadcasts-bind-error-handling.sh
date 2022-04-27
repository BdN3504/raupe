#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
httpResponseCode=$1
responseFile=$2
callingScript=$3
case $httpResponseCode in
  200)
    exit 0
  ;;
  400)
    reason=$(jq -r .error.errors[0].reason "$responseFile")
    case $reason in
      "idRequired")
        echo "The required id parameter must identify the broadcast to bind."
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
  403)
    reason=$(jq -r .error.errors[0].reason "$responseFile")
    case $reason in
      "liveBroadcastBindingNotAllowed")
        echo "The current status of the live broadcast does not allow it to be bound to a stream."
        exit 1
      ;;
    esac
  ;;
  404)
    reason=$(jq -r .error.errors[0].reason "$responseFile")
    case $reason in
      "liveBroadcastNotFound")
        echo "The broadcast specified by the id parameter does not exist."
        exit 1
      ;;
      "liveStreamNotFound")
        echo "The stream specified by the streamId parameter does not exist."
        exit 1
      ;;
    esac
  ;;
esac
