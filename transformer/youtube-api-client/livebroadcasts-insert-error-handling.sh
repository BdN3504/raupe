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
      "invalidAutoStart")
        echo "The liveBroadcast resource contained an invalid value for the contentDetails.enableAutoStart property. Not all broadcasts support this setting."
        exit 1
      ;;
      "invalidAutoStop")
        echo "The liveBroadcast resource contained an invalid value for the contentDetails.enableAutoStop property. You cannot modify the enableAutoStop setting for a persistent broadcast."
        exit 1
      ;;
      "invalidDescription")
        echo "The liveBroadcast resource did not specify a valid value for the snippet.description property. The property's value can contain up to 5000 characters."
        exit 1
      ;;
      "invalidEmbedSetting")
        echo "The liveBroadcast resource contained an invalid value for the contentDetails.enable_embed property. You cannot embed this broadcast."
        exit 1
      ;;
      "invalidLatencyPreferenceOptions")
        echo "The liveBroadcast resource contained an invalid value for the contentDetails.latencyPreference property. Not all settings are supported with this latency preference. "
        exit 1
      ;;
      "invalidPrivacyStatus")
        echo "The liveBroadcast resource contained an invalid value for the status.privacy_status property."
        exit 1
      ;;
      "invalidProjection")
        echo "The liveBroadcast resource contained an invalid value for the contentDetails.projection property. A default broadcast's projection cannot be set to 360."
        exit 1
      ;;
      "invalidScheduledEndTime")
        echo "The liveBroadcast resource contained an invalid value for the snippet.scheduledEndTime property. The scheduled end time must follow the scheduled start time."
        exit 1
      ;;
      "invalidScheduledStartTime")
        echo "The liveBroadcast resource contained an invalid value for the snippet.scheduledStartTime property. The scheduled start time must be in the future and close enough to the current date that a broadcast could be reliably scheduled at that time."
        exit 1
      ;;
      "invalidTitle")
        echo "The liveBroadcast resource did not specify a valid value for the snippet.title property. The property's value must be between 1 and 100 characters long."
        exit 1
      ;;
      "privacyStatusRequired")
        echo "The liveBroadcast resource must specify a privacy status. See valid privacyStatus values."
        exit 1
      ;;
      "scheduledEndTimeRequired")
        echo "The liveBroadcast resource must specify the snippet.scheduledEndTime property."
        exit 1
      ;;
      "scheduledStartTimeRequired")
        echo "The liveBroadcast resource must specify the snippet.scheduledStartTime property."
        exit 1
      ;;
      "titleRequired")
        echo "The liveBroadcast resource must specify the snippet.title property."
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
