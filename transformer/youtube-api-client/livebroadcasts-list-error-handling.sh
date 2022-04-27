#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
httpResponseCode=$1
responseFile=$2
callingScript=$3

case $httpResponseCode in
  200)
    cat "$responseFile"
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
