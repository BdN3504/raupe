#!/bin/bash
oAuthRequest=req.http
screenSession=oAuthRedirect
[ -f $oAuthRequest ] && rm $oAuthRequest
./toggle-socat-unprivileged-access-to-low-tcp-ports.sh "enable"
screen -S $screenSession -dm \
socat openssl-listen:443,cert=./certs/fullchain.pem,key=./certs/privkey.pem,verify=0,reuseaddr,fork exec:"/bin/bash server.sh $oAuthRequest"
until [ -f $oAuthRequest ]; do echo "Waiting for Authentication requests" && sleep 5;done
screen -S $screenSession -X quit
./toggle-socat-unprivileged-access-to-low-tcp-ports.sh "disable"
code=$(/bin/bash ./get-auth-code-from-request.sh 2>&1)
echo $code
