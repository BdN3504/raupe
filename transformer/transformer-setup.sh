#!/bin/bash
./transformer-variables.sh -s
./youtube-api-client/client-variables.sh -s
./youtube-api-client/access-token-retrieve.sh
./youtube-api-client/access-token-refresh.sh
./youtube-api-client/authentication-check.sh
