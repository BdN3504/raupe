#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$streamsDeleteResponse
if [ -n "$1" ]; then
  streamId="$1"
else
  streamId=$(jq -r .id "$scriptPath/$streamsInsertResponse")
fi

httpResponseCode=$(curl \
  -s \
  -w "%{http_code}" \
  --request DELETE \
  "$liveStreamsEndpoint?id=$streamId" \
  --header "Accept: application/json" \
  --header "Authorization: Bearer $access_token" \
  --compressed \
  -o "$scriptPath/$responseFile")

case $httpResponseCode in
  401)
    echo "http code: $httpResponseCode"
    cat "$responseFile"
    sleep 1
    ./authentication-check.sh
    ./"$0"
    exit 1
  ;;

  403)
    reason=$(jq -r .error.errors[0].reason "$scriptPath/$responseFile")
    case $reason in
      "liveStreamDeletionNotAllowed")
        echo "The specified live stream cannot be deleted because it is bound to a broadcast that has still not completed."
        exit 1
      ;;
    esac
  ;;

  404)
    echo "Stream $streamId does not exist."
    cat "$scriptPath/$responseFile"
    exit 1
  ;;

  204)
    echo "Successfully deleted $streamId. Cleaning up response files."

    rm \
    "$scriptPath/$responseFile" \
    "$scriptPath/$streamsInsertResponse"

    screen -S raupe -X quit

    exit 0
  ;;
esac
