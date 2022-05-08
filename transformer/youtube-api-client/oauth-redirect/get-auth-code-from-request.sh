#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

oAuthRequest="$scriptPath/req.http"
[ ! -f "$oAuthRequest" ] && echo "oAuth Redirection request not yet received." && exit 1
urlParams=$(grep -Po "^GET .*code=\K[^ ]*" "$oAuthRequest")
decodedUrlParams=$(urldecode "$urlParams")
if [[ $decodedUrlParams == *"scope=https://www.googleapis.com/auth/youtube.force-ssl"* ]]; then
  code=${decodedUrlParams%&*}
  echo "$code"
fi
