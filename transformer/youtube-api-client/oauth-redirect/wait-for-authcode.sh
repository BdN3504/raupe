#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))

oAuthRequest="$scriptPath/req.http"
serverScript="$scriptPath/server.sh"
socatScript="$scriptPath/toggle-socat-unprivileged-access-to-low-tcp-ports.sh"
getAuthCodeScript="$scriptPath/get-auth-code-from-request.sh"
certPath="$scriptPath/certs/fullchain.pem"
keyPath="$scriptPath/certs/privkey.pem"
scope="$1"
screenSession=oAuthRedirect
[ -f "$oAuthRequest" ] && rm "$oAuthRequest"
/bin/bash "$socatScript" "enable"
screen -S $screenSession -dm \
socat openssl-listen:443,cert="$certPath",key="$keyPath",verify=0,reuseaddr,fork exec:"/bin/bash $serverScript $oAuthRequest"
until [ -f "$oAuthRequest" ]; do echo "Waiting for authorization redirect request." && sleep 5;done
screen -S $screenSession -X quit
/bin/bash "$socatScript" "disable"
/bin/bash "$getAuthCodeScript" "$scope"
