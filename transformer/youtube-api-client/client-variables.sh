#!/bin/bash

code=
client_id=
client_secret=
redirect_uri=

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
playlistsEndpoint="$apiBaseUrl/$apiName/$apiVersion/playlists"
playlistItemsEndpoint="$apiBaseUrl/$apiName/$apiVersion/playlistItems"

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
playlistsListMineResponse=.playlists-list-mine-response.json
playlistsInsertResponse=.playlists-insert-response.json
playlistItemsInsertResponse=.playlistItems-insert-response.json

streamTitle="Stream title"
streamDescription="Stream description"

broadcastTitle="Broadcast title"
broadcastDescription="Broadcast description"

playlistTitle="Playlist title"
playlistDescription="Playlist description"
playlistDescriptionLanguage="en"
playlistVisibility="unlisted"

while getopts ":st:" opt; do
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

      echo "To acquire an authorization code, you need to have a working ssl endpoint that can receive requests from \
      the Google oAuth flow. If this software is running on a server that does not have a commercial ssl certificate, \
      you can use the letsencrypt certbot client alongside a domain provided by duckdns.org to enable an ssl webserver. \
      Once you have certbot setup and the certificate files reside in your /etc/letsencrypt/live/<subdirectories>, you \
      can copy your fullchain.pem and privkey.pem certificates to the oauth-redirect/certs directory. This script will \
      then automatically enable an https server for the specified domain, listen for the authorization code request and \
      save the authorization code to retrieve the access token."

      read -re -i "$redirect_uri" -p "Provide the https redirect uri that is defined for the client in the google developer console here: " redirect_uriInput
      redirect_uri=${redirect_uriInput:-$credirect_uri}
      sed -i -E "s%^(redirect_uri=).*$%\1$redirect_uri%g" "$self"

      echo "Visit the following url in a browser \
      $authorization_endpoint?client_id=$client_id&redirect_uri=$redirect_uri&scope=$scope&prompt=consent&response_type=code&access_type=offline"

      scriptPath=$(dirname $(realpath -s "$0"))
      oauthRedirectPath="$scriptPath/oauth-redirect"
      /bin/bash "$oauthRedirectPath/wait-for-authcode.sh" "$scope"
      authCode=$(cat "$oauthRedirectPath/authCode")
      sed -i -E "s%^(code=).*$%\1$authCode%g" "$self"

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

      read -re -i "$playlistTitle" -p "Specify the title of the playlist \
      to which all the videos for this streaming series will be added to: " playlistTitleInput
      playlistTitle=${playlistTitleInput:-$playlistTitle}
      sed -i -E "s%^(playlistTitle=).*$%\1\"$playlistTitle\"%g" "$self"

      read -re -i "$playlistDescription" -p "Specify the description of the playlist: " playlistDescriptionInput
      playlistDescription=${playlistDescriptionInput:-$playlistDescription}
      sed -i -E "s%^(playlistDescription=).*$%\1\"$playlistDescription\"%g" "$self"

      read -re -i "$playlistDescriptionLanguage" -p "Provide a two letter language code which the playlist \
      title and description use: " playlistDescriptionLanguageInput
      playlistDescriptionLanguage=${playlistDescriptionLanguageInput:-$playlistDescriptionLanguage}
      sed -i -E "s%^(playlistDescriptionLanguage=).*$%\1\"$playlistDescriptionLanguage\"%g" "$self"

      read -re -i "$playlistVisibility" -p "Specify the visibility of the playlist (private, public or unlisted): " playlistVisibilityInput
      playlistVisibility=${playlistVisibilityInput:-$playlistVisibility}
      sed -i -E "s%^(playlistVisibility=).*$%\1\"$playlistVisibility\"%g" "$self"
      ;;
    t)
      self=$(realpath "$0")
      sed -i -E "s%^(broadcastTitle=).*$%\1\"$OPTARG\"%g" "$3"
      ;;
    \?)
      ;;
  esac
done
