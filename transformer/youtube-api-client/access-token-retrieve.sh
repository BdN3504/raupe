#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
. "$scriptPath/client-variables.sh"

responseFile=$tokenRetrieveResponse

httpResponseCode=$(curl \
  -s \
  -w "%{http_code}" \
  --location \
  --request POST "$token_endpoint" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "code=$code" \
  --data-urlencode "client_id=$client_id" \
  --data-urlencode "client_secret=$client_secret" \
  --data-urlencode "redirect_uri=$redirect_uri" \
  --data-urlencode "grant_type=$grant_type_Authorization_code" \
  -o "$scriptPath/$responseFile")

if (($httpResponseCode > 200)); then
  echo "Retrieving access token failed."
  cat "$scriptPath/$responseFile"
  exit 1
fi

refresh_token=$(jq -r .refresh_token "$scriptPath/$responseFile")
echo $refresh_token > "$scriptPath/$refreshToken"

sed -i -E "s%^(code=).*$%\1%g" "$scriptPath/client-variables.sh"
