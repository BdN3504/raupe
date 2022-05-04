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
      "invalidContentDetails")
        echo "The contentDetails property in the request is not valid. A possible reason is that contentDetails.note field is longer than 280 characters."
        exit 1
      ;;
      "invalidPlaylistItemPosition")
        echo "The request attempts to set the playlist item's position to an invalid or unsupported value. Check the value of the position property in the resource's snippet."
        exit 1
      ;;
      "invalidResourceType")
        echo "The type specified for the resource ID is not supported for this operation. The resource ID identifies the item being added to the playlist – e.g. youtube#video."
        exit 1
      ;;
      "manualSortRequired")
        echo "The request attempts to set the playlist item's position, but the playlist does not use manual sorting.\
         (For example, playlist items might be sorted by date or popularity.)\
         You can address the error by removing the snippet.position element from the resource that the request is \
         inserting. If you want the playlist item to have a particular position in the list, you need to first update \
         the playlist's Ordering option to Manual in the playlist's settings. This settings can be adjusted in the \
         YouTube Video Manager."
        exit 1
      ;;
      "videoAlreadyInAnotherSeriesPlaylist")
        echo "The video that you are trying to add to the playlist is already in another series playlist."
        exit 1
      ;;
      "channelIdRequired")
        echo "The request does not specify a value for the required channelId property."
        exit 1
      ;;
      "playlistIdRequired")
        echo "The request does not specify a value for the required playlistId property."
        exit 1
      ;;
      "resourceIdRequired")
        echo "The request must contain a resource in which the snippet object specifies a resourceId."
        exit 1
      ;;
      "playlistOperationUnsupported")
        echo "The API does not support the ability to insert videos into the specified playlist. For example, \
        you can't insert a video into your uploaded videos playlist."
        exit 1
      ;;
    esac
  ;;
  403)
    reason=$(jq -r .error.errors[0].reason "$responseFile")
    case $reason in
      "playlistContainsMaximumNumberOfVideos")
        echo "The playlist already contains the maximum allowed number of items."
        exit 1
      ;;
      "playlistItemsNotAccessible")
        echo "The request is not properly authorized to insert the specified playlist item."
        exit 1
      ;;
    esac
  ;;
  404)
    reason=$(jq -r .error.errors[0].reason "$responseFile")
    case $reason in
      "playlistNotFound")
        echo "The playlist identified with the request's playlistId parameter cannot be found."
        exit 1
      ;;
      "videoNotFound")
        echo "The video that you are trying to add to the playlist cannot be found. \
        Check the value of the videoId property to ensure that it is correct."
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
