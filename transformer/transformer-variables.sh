#!/bin/bash
rtspServerPort=8554
rtspServerHost=
rtspStreamPath=/unicast
logDir=
videoStreamBitrate=9000k
videoStreamFramerate=30
videoStreamResolution=1920x1080
videoStreamBufferSize=1024k

while getopts ":s" opt; do
  case $opt in
    s)
      self=$(realpath "$0")

      read -re -i "$rtspServerPort" -p "Define the tcp port the rtsp server on the capture device is listening on: " rtspServerPortInput
      rtspServerPort=${rtspServerPortInput:-$rtspServerPort}
      sed -i -E "s|^(rtspServerPort=)[0-9]*$|\1$rtspServerPort|g" "$self"

      read -re -i "$rtspServerHost" -p "Define the host address of the capture device: " rtspServerHostInput
      rtspServerHost=${rtspServerHostInput:-$rtspServerHost}
      sed -i -E "s%^(rtspServerHost=).*$%\1$rtspServerHost%g" "$self"

      read -re -i "$rtspStreamPath" -p "Define the path of the rtsp stream on the capture device: " rtspStreamPathInput
      rtspStreamPath=${rtspStreamPathInput:-$rtspStreamPath}
      sed -i -E "s%^(rtspStreamPath=).*$%\1$rtspStreamPath%g" "$self"

      read -re -i "$logDir" -p "Specify the directory where logs will be stored: " logDirInput
      logDir=${logDirInput:-$logDir}
      sed -i -E "s%^(logDir=).*$%\1$logDir%g" "$self"

      echo "The bitrate of the video you are going to stream should correlate to the upload speed of your internet \
      connection. Use a value of around 80% of that speed, specify the value in kilobytes by appending the letter 'k'. \
      This value only represents a recommendation for ffmpeg to use, so the actual bitrate will vary."
      read -re -i "$videoStreamBitrate" -p "Specify the bitrate of the video stream: " videoStreamBitrateInput
      videoStreamBitrate=${videoStreamBitrateInput:-$videoStreamBitrate}
      sed -i -E "s%^(videoStreamBitrate=).*$%\1$videoStreamBitrate%g" "$self"

      echo "Specify the framerate of the stream source. Needs to be one of the values supported by youtube: \
      https://developers.google.com/youtube/v3/live/docs/liveStreams#cdn.frameRate Only provide a number, \
      so either 30 or 60."
      read -re -i "$videoStreamFramerate" -p "Specify the frame rate of the video stream: " videoStreamFramerateInput
      videoStreamFramerate=${videoStreamFramerateInput:-$videoStreamFramerate}
      sed -i -E "s|^(videoStreamFramerate=)[0-9]*$|\1$videoStreamFramerate|g" "$self"

      echo "Specify the resolution of the stream source. Needs to be one of the values supported by youtube: \
      https://support.google.com/youtube/answer/2853702
      Values need to adhere to the format '<Width>x<Height>'."
      read -re -i "$videoStreamResolution" -p "Specify the resolution of the video stream: " videoStreamResolutionInput
      videoStreamResolution=${videoStreamResolutionInput:-$videoStreamResolution}
      sed -i -E "s%^(videoStreamResolution=).*$%\1$videoStreamResolution%g" "$self"

      echo "Specify the buffer size of the stream source. Dividing the bitrate by the buffer size yields a value which
      tells you how often ffmpeg will try to adjust the bitrate. Append a 'k' for kilobytes."
      read -re -i "$videoStreamBufferSize" -p "Specify the buffer size of the video stream: " videoStreamBufferSizeInput
      videoStreamBufferSize=${videoStreamBufferSizeInput:-$videoStreamBufferSize}
      sed -i -E "s%^(videoStreamBufferSize=).*$%\1$videoStreamBufferSize%g" "$self"

      exit 0
      ;;
    \?)
      ;;
  esac
done
