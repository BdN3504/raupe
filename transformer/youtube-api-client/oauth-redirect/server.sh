#!/bin/bash
request=$(head -1)
requestFile=$1
echo "$request" >> "$requestFile"
echo "It works"
