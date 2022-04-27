#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$broadcastsDeleteResponse

if [ -n "$1" ]; then
	broadcastId="$1"
else
  broadcastId=$(jq -r .id "$scriptPath/$broadcastsInsertResponse")
fi

httpResponseCode=$(curl \
  -s \
  -w "%{http_code}" \
  --request DELETE \
  "$liveBroadcastsEndpoint?id=$broadcastId" \
  --header "Authorization: Bearer $access_token" \
  --header "Accept: application/json" \
  --compressed \
  -o "$scriptPath/$responseFile")

case $httpResponseCode in
  204)
    echo "Successfully deleted $broadcastId. Cleaning up response files."
    rm \
    "$scriptPath/$broadcastsInsertResponse" \
    "$scriptPath/$responseFile"
  ;;
  401)
    echo "Authentication failed"
    cat "$scriptPath/$responseFile"
    sleep 1
    /bin/bash "$scriptPath/authentication-check.sh"
    /bin/bash "$(realpath "$0")"
    exit 1
  ;;
  403)
    reason=$(jq -r .error.errors[0].reason "$responseFile")
    case $reason in
      "liveBroadcastDeletionNotAllowed")
        echo "The current status of the live broadcast does not allow it to be deleted."
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


