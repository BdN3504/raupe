#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

[ -z "$client_id" ] && echo "OAuth client id is missing, run transformer-setup.sh" && exit 1
[ -z "$client_secret" ] && echo "OAuth client secret is missing, run transformer-setup.sh" && exit 1
[ ! -f "$scriptPath/$refreshToken" ] && echo "Refreshtoken has not been retrieved yet, assuming authentication was not done. Exiting." && exit 1
[ ! -f "$scriptPath/$tokenRefreshResponse" ] && echo "Token has not been refreshed yet." && "$scriptPath/access-token-refresh.sh" && exit 0
access_token=$(jq -r .access_token "$scriptPath/$tokenRefreshResponse")
responseFile=$channelsMineResponse

httpResponseCode=$(curl \
  -s \
  -w "%{http_code}" \
  --request GET \
  "$channelsEndpoint?part=id&mine=true" \
  --header "Authorization: Bearer $access_token" \
  --header "Accept: application/json" \
  --compressed \
  -o "$scriptPath/$responseFile")

case $httpResponseCode in
  200)
    echo "Authentication succeeded"
    exit 0
  ;;
  401)
    echo "Token has been refreshed before but seems to be invalid. Going to refresh the token now."
    cat "$scriptPath/$responseFile"
    "$scriptPath/access-token-refresh.sh"
    "$(realpath "$0")"
    exit 1
  ;;
esac
