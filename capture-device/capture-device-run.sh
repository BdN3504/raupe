#!/bin/bash
screen -S raupe -dm v4l2rtspserver /dev/video0 -W 1920 -H 1080 -G 1920x1080
v4l2-ctl --set-ctrl vertical_flip=1
v4l2-ctl --set-ctrl horizontal_flip=1
