# raupe
## Description

This repository contains info & bash scripts to create a YouTube live stream from a raspberry
pi [camera module](https://www.raspberrypi.com/products/camera-module-v2/).

The setup provides that two raspberry pis are used to create the stream: One which captures the
video and another one which transforms the captured video into a format that can be streamed on
YouTube.

A YouTube channel activated for streaming needs to be present before proceeding. Activation takes more
than 24 hours.

## Usage
Start a capture on the capture device by running [capture-device-run.sh](/capture-device/capture-device-run.sh). Set up the transformer
by running [transformer-setup.sh](/transformer/transformer-setup.sh). Set up the stream by running [stream-setup.sh](/transformer/stream-setup.sh). Start streaming
by running [transformer-run.sh](/transformer/transformer-run.sh) or better yet create a cron job that runs transformer-run.sh
every minute. See below for requirements.

## Capture device

The capture device uses [v4l2rtspserver](https://github.com/mpromonet/v4l2rtspserver) to create an rtsp stream. v4l2rtspserver does not support
the new [unicam interface provided by debian bullseye](https://github.com/mpromonet/v4l2rtspserver/issues/257). Therefore,
the legacy camera interface needs to be [enabled with raspi-config](https://www.raspberrypi.com/documentation/accessories/camera.html#libcamera-and-the-legacy-raspicam-camera-stack).
This provides the `bcm2835-v4l2` interface which is compatible with the rtspserver. `v4l2-ctl 
--list-devices` can be used to see the interfaces available.

`v4l2rtspserver` needs to be compiled from source. It is enough to run 
```
sudo apt install git cmake
git clone https://github.com/mpromonet/v4l2rtspserver.git
cd v4l2rtspserver
cmake . && make && sudo make install
```
on the capture device. After successful compilation, the rtsp stream can be started by running the [capture-device-run.sh](/capture-device/capture-device-run.sh) script.
Adjustments to the video source can be made by invoking `v4l2-ctl`. Use `v4l2-ctl -l` to see
the adjustments supported by your camera.

## Transformer

To consume the stream, `ffmpeg` needs to be installed on the transformer. Use [this command](https://stackoverflow.com/a/42747348/854483) to transform
the [rtsp](https://datatracker.ietf.org/doc/html/rfc2326) stream into a [rtmp](http://web.archive.org/web/20210909154508/https://wwwimages2.adobe.com/content/dam/acom/en/devnet/rtmp/pdf/rtmp_specification_1.0.pdf) stream and send it to YouTube:
```
ffmpeg -re -rtsp_transport tcp -i "rtsp://<capture_device_host>:<port>/unicast" \
       -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
       -c:a libmp3lame -ab 128k -ar 44100 \
       -c:v copy -threads 2 -bufsize 512k \
       -f flv "rtmp://a.rtmp.youtube.com/live2/<live-stream-key>"
```

### YouTube data api

The `<live-stream-key>` can be obtained by querying the YouTube data api. To use the api, an access
token is required. To request an access token, the [Google auth endpoint](https://accounts.google.com/o/oauth2/v2/auth) needs to be called with the
appropriate scope, the `client_id` and the `access_type` parameter set to `offline`. This will
result in an authorization response that contains a refresh token which must be used to retrieve
subsequent access tokens.

To set up authentication, an application in the [Google developer console](https://console.developers.google.com) needs to be created.
The [YouTube data api](https://console.cloud.google.com/apis/library/youtube.googleapis.com) needs to be enabled and an [oauth client](https://console.cloud.google.com/apis/credentials/oauthclient) desktop application needs to be 
created. The last step is to create an [OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent).

After authentication has been configured, the oauth client credentials need to be provided to
the transformer. This can be done by running the [client-variables.sh](/transformer/youtube-api-client/client-variables.sh) script.

The transformer contains scripts using the YouTube data api. To start a live stream, a [`livestream resource`](https://developers.google.com/youtube/v3/live/docs/liveStreams#resource)
needs to be [`inserted`](https://developers.google.com/youtube/v3/live/docs/liveStreams/insert). The data is fed to the livestream with the `ffmpeg` command. To view the livestream
on YouTube, a [`livebroadcast resource`](https://developers.google.com/youtube/v3/live/docs/liveBroadcasts#resource) needs to be created and [`bound`](https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/bind#streamId) to the `livestream resource`
via the livestream [`id`](https://developers.google.com/youtube/v3/live/docs/liveStreams#id). After the broadcast is successfully bound to the livestream, it needs to
be [`transitioned`](https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/transition#broadcastStatus) to the [`live`](https://developers.google.com/youtube/v3/live/docs/liveBroadcasts#status.lifeCycleStatus) status.

All the http requests are made with [curl](https://curl.se/). Json parsing is done with [jq](https://stedolan.github.io/jq/).