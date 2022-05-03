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
      "defaultLanguageNotSetError")
        echo "The defaultLanguage must be set to update localizations."
        exit 1
      ;;
      "localizationValidationError")
        echo "One of the values in the localizations object failed validation. Use the playlists.list
        method to retrieve valid values and make sure to update them following the guidelines in the playlists resource documentation."
        exit 1
      ;;
      "maxPlaylistExceeded")
        echo "The playlist cannot be created because the channel already has the maximum number of playlists allowed."
        exit 1
      ;;
      "invalidPlaylistSnippet")
        echo "The request provides an invalid playlist snippet."
        exit 1
      ;;
      "playlistTitleRequired")
        echo "The request must specify a playlist title."
        exit 1
      ;;
    esac
  ;;
  403)
    reason=$(jq -r .error.errors[0].reason "$responseFile")
    case $reason in
      "playlistForbidden")
        echo "The playlist identified with the request's id parameter does not support the request or the request is not properly authorized."
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
