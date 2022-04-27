#!/bin/bash

code=
client_id=
client_secret=
redirect_uri=urn:ietf:wg:oauth:2.0:oob

oAuthApiDiscoveryUrl=https://accounts.google.com/.well-known/openid-configuration
authorization_endpoint=https://accounts.google.com/o/oauth2/v2/auth
token_endpoint=https://oauth2.googleapis.com/token
grant_type_Authorization_code=authorization_code
grant_type_Refresh_token=refresh_token

apiName=youtube
apiBaseUrl="https://$apiName.googleapis.com"
apiDiscoveryUrl="$apiBaseUrl/\$discovery/rest?version=v3"
apiVersion=v3
liveBroadcastsEndpoint="$apiBaseUrl/$apiName/$apiVersion/liveBroadcasts"
liveStreamsEndpoint="$apiBaseUrl/$apiName/$apiVersion/liveStreams"
channelsEndpoint="$apiBaseUrl/$apiName/$apiVersion/channels"

scope=https://www.googleapis.com/auth/youtube.force-ssl

oauthCredentialsUrl=https://console.cloud.google.com/apis/credentials

refreshToken=.refresh-token
tokenRefreshResponse=.access-token-refresh-response.json
tokenRetrieveResponse=.access-token-retrieve-response.json
channelsMineResponse=.channels-mine-response.json
broadcastsBindResponse=.livebroadcasts-bind-response.json
broadcastsDeleteResponse=.livebroadcasts-delete-response.json
broadcastsInsertResponse=.livebroadcasts-insert-response.json
broadcastsListActiveResponse=.livebroadcasts-list-active-response.json
broadcastsListAllResponse=.livebroadcasts-list-all-response.json
broadcastsListDefaultResponse=.livebroadcasts-list-default-response.json
broadcastsListInsertedResponse=.livebroadcasts-list-inserted-response.json
broadcastsTransitionCompleteResponse=.livebroadcasts-transition-complete-response.json
broadcastsTransitionErrorHandlingResponse=.livebroadcasts-transition-error-handling-response.json
broadcastsTransitionLiveResponse=.livebroadcasts-transition-live-response.json
broadcastsTransitionTestingResponse=.livebroadcasts-transition-testing-response.json
streamsDeleteResponse=.livestreams-delete-response.json
streamsInsertResponse=.livestreams-insert-response.json
streamsListInsertedResponse=.livestreams-list-inserted-response.json
streamsListMineResponse=.livestreams-list-mine-response.json

streamTitle="Stream title"
streamDescription="Stream description"

broadcastTitle="Broadcast title"
broadcastDescription="Broadcast description"

while getopts ":s" opt; do
  case $opt in
    s)
      self=$(realpath "$0")

      echo "Visit the developer console api credentials url in a browser: https://console.cloud.google.com/apis/credentials"
      read -re -i "$client_id" -p "Provide the oAuth client id: " client_idInput
      client_id=${client_idInput:-$client_id}
      sed -i -E "s%^(client_id=).*$%\1$client_id%g" "$self"

      read -re -i "$client_secret" -p "Provide the oAuth client secret: " client_secretInput
      client_secret=${client_secretInput:-$client_secret}
      sed -i -E "s%^(client_secret=).*$%\1$client_secret%g" "$self"

      echo "Visit the following url in a browser \
      $authorization_endpoint?client_id=$client_id&redirect_uri=$redirect_uri&scope=$scope&response_type=code&access_type=offline"

      read -re -i "$code" -p "Paste the code that is displayed in your browser here: " codeInput
      code=${codeInput:-$code}
      sed -i -E "s%^(code=).*$%\1$code%g" "$self"

      read -re -i "$streamTitle" -p "Specify the title of the stream: " streamTitleInput
      streamTitle=${streamTitleInput:-$streamTitle}
      sed -i -E "s%^(streamTitle=).*$%\1\"$streamTitle\"%g" "$self"

      read -re -i "$streamDescription" -p "Specify the description of the stream: " streamDescriptionInput
      streamDescription=${streamDescriptionInput:-$streamDescription}
      sed -i -E "s%^(streamDescription=).*$%\1\"$streamDescription\"%g" "$self"

      read -re -i "$broadcastTitle" -p "Specify the title of the broadcast: " broadcastTitleInput
      broadcastTitle=${broadcastTitleInput:-$broadcastTitle}
      sed -i -E "s%^(broadcastTitle=).*$%\1\"$broadcastTitle\"%g" "$self"

      read -re -i "$broadcastDescription" -p "Specify the description of the broadcast: " broadcastDescriptionInput
      broadcastDescription=${broadcastDescriptionInput:-$broadcastDescription}
      sed -i -E "s%^(broadcastDescription=).*$%\1\"$broadcastDescription\"%g" "$self"
      ;;
    \?)
      ;;
  esac
done
