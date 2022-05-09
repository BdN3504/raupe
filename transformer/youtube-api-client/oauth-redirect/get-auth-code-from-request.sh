#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))

authCode="$scriptPath/authCode"
scope="$1"

function urlDecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

oAuthRequest="$scriptPath/req.http"
[ ! -f "$oAuthRequest" ] && echo "oAuth Redirection request not yet received." && exit 1
urlParams=$(grep -Po "^GET .*code=\K[^ ]*" "$oAuthRequest")
decodedUrlParams=$(urlDecode "$urlParams")
if [[ $decodedUrlParams == *"scope=$scope"* ]]; then
  code=${decodedUrlParams%&*}
  echo "$code" > "$authCode"
fi
