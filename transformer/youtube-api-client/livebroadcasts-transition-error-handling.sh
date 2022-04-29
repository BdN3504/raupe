#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
httpResponseCode=$1
responseFile=$2
callingScript=$3
case $httpResponseCode in
  200)
    cat "$responseFile"
    exit 0
  ;;
  400)
    reason=$(jq -r .error.errors[0].reason "$responseFile")
    case $reason in
      "idRequired")
        echo "The required id parameter must identify the broadcast whose status you want to transition."
        exit 1
      ;;
      "statusRequired")
        echo "The API request must specify a value for the status parameter."
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
      "errorStreamInactive")
        echo "The requested transition is not allowed when the stream that is bound to the broadcast is inactive."
        /bin/bash "$scriptPath/../stream-wait-for-data.sh"
        exit 1
      ;;
      "invalidTransition")
        echo "The live broadcast can't transition from its current status to the requested status. $callingScript"
        /bin/bash "$scriptPath/livebroadcasts-list-inserted.sh"
        sleep 10
        /bin/bash "$callingScript"
        exit 1
      ;;
      "redundantTransition")
        echo "The live broadcast is already in the requested status or processing to the requested status. $callingScript"
        /bin/bash "$scriptPath/livebroadcasts-list-inserted.sh"
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
    esac
  ;;
esac
