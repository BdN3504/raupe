#!/bin/bash
scriptPath=$(dirname $(realpath -s "$0"))
youtubeApiClientPath="$scriptPath/youtube-api-client"

. "$scriptPath/transformer-variables.sh"
. "$youtubeApiClientPath/client-variables.sh"

mkdir -p "$logDir"
logFile=$logDir/log.txt

streamKey=$(jq -r .cdn.ingestionInfo.streamName "$youtubeApiClientPath/$streamsInsertResponse")
youtubeStreamAddress=$(jq -r .cdn.ingestionInfo.ingestionAddress  "$youtubeApiClientPath/$streamsInsertResponse")

echo "Going to use this ffmpeg command: \
	  ffmpeg -re \
	  -rtsp_transport tcp \
	  -i \"rtsp://$rtspServerHost:$rtspServerPort$rtspStreamPath\" \
	  -f lavfi \
	  -i anullsrc=channel_layout=stereo:sample_rate=44100 \
	  -c:a libmp3lame -ab 32k -ar 44100 \
	  -framerate $videoStreamFramerate \
	  -b:v $videoStreamBitrate \
	  -maxrate $videoStreamBitrate \
	  -video_size $videoStreamResolution \
	  -c:v copy \
	  -threads 2 \
	  -bufsize $videoStreamBufferSize \
	  -f flv \"$youtubeStreamAddress/$streamKey\"" >> "$logFile"
ffmpegPid=$(ps -C ffmpeg -o pid=)
if ((ffmpegPid > 0)); then
	echo "ffmpeg pid gt 0" >> "$logFile"
	firstCaptureTimestamp=$(timeout .5 strace -p$ffmpegPid -s9999 2>&1 | grep -oh "time=[[:digit:]]*:[[:digit:]]*:[[:digit:]]*\.[[:digit:]]*")
	echo "$firstCaptureTimestamp" >> "$logFile"
	sleep 1
	secondCaptureTimestamp=$(timeout .5 strace -p$ffmpegPid -s9999 2>&1 | grep -oh "time=[[:digit:]]*:[[:digit:]]*:[[:digit:]]*\.[[:digit:]]*")
	echo "$secondCaptureTimestamp" >> "$logFile"
	if [ "$firstCaptureTimestamp" = "$secondCaptureTimestamp" ]; then
	  echo "Same timestamps found, restarting ffmpeg" >> "$logFile"
	  screen -S raupe -X quit
	  sleep 1
    screen -S raupe -dm \
	  ffmpeg -re \
	  -rtsp_transport tcp \
	  -i "rtsp://$rtspServerHost:$rtspServerPort$rtspStreamPath" \
	  -f lavfi \
	  -i anullsrc=channel_layout=stereo:sample_rate=44100 \
	  -c:a libmp3lame -ab 32k -ar 44100 \
	  -framerate $videoStreamFramerate \
	  -b:v $videoStreamBitrate \
	  -maxrate $videoStreamBitrate \
	  -video_size $videoStreamResolution \
	  -c:v copy \
	  -threads 2 \
	  -bufsize $videoStreamBufferSize \
	  -f flv "$youtubeStreamAddress/$streamKey"
	  echo "Started a new ffmpeg process" >> "$logFile"
	else
    echo "Timestamps differ, no need to do anything, going to exit." >> "$logFile"
    exit 0
	fi
else
  echo "ffmpeg is not running, starting" >> "$logFile"
  screen -S raupe -dm \
  ffmpeg -re \
  -rtsp_transport tcp \
  -i "rtsp://$rtspServerHost:$rtspServerPort$rtspStreamPath" \
  -f lavfi \
  -i anullsrc=channel_layout=stereo:sample_rate=44100 \
  -c:a libmp3lame -ab 32k -ar 44100 \
  -framerate $videoStreamFramerate \
  -b:v $videoStreamBitrate \
  -maxrate $videoStreamBitrate \
  -video_size $videoStreamResolution \
  -c:v copy \
  -threads 2 \
  -bufsize $videoStreamBufferSize \
  -f flv "$youtubeStreamAddress/$streamKey"
  sleep 1
  echo "Started ffmpeg" >> "$logFile"
  ffmpegPid=$(ps -C ffmpeg -o pid=)
  timestamp=$(timeout 5 strace -p$ffmpegPid -s9999 2>&1 | grep -oh "time=[[:digit:]]*:[[:digit:]]*:[[:digit:]]*\.[[:digit:]]*")
  echo "$timestamp" >> "$logFile"
fi
