#!/bin/bash
cd /home/pi/raupe/transformer

echo "Checking authentication"
./youtube-api-client/authentication-check.sh

numberOfDaysPassed=$("./youtube-api-client/get-number-of-days-since-start-of-stream.sh")
./youtube-api-client/livebroadcasts-transition-complete.sh
newTitle="Caterpillar live broadcast - Vanessa Cardui - day $numberOfDaysPassed"
./youtube-api-client/client-variables.sh -t "$newTitle"
./youtube-api-client/livebroadcasts-insert.sh
./youtube-api-client/livebroadcasts-bind.sh
./youtube-api-client/livebroadcasts-transition-testing.sh
sleep 10
./youtube-api-client/livebroadcasts-transition-live.sh
