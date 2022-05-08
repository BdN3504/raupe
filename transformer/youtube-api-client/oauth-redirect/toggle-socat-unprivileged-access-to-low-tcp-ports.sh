#!/bin/bash
socatPath=$(type -p socat)
allowAccess=$1
if [ $allowAccess = "enable" ]; then
  sudo setcap CAP_NET_BIND_SERVICE=+eip "$socatPath"
elif [ $allowAccess = "disable" ]; then
  sudo setcap CAP_NET_BIND_SERVICE=-eip "$socatPath"
fi
