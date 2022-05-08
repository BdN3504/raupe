#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))

oAuthRequest="$scriptPath/req.http"
[ ! -f "$oAuthRequest" ] && echo "oAuth Redirection request not yet received." && exit 1
urlParams=$(grep -Po "^GET .*code=\K[^ ]*" "$oAuthRequest")
if [[ $urlParams == *"scope=https://www.googleapis.com/auth/youtube.force-ssl"* ]]; then
  code=${urlParams%&*}
  echo "$code"
fi
