#!/bin/bash
usage() {
  echo "Usage: $0 -u <rtmp url>"
  echo "Options:"
  echo "  -u <url>    RTMP url sink"
  echo "  -k <key>    Stream key"
  exit 1
}

url=""
key=""
opts="u:k:"
while getopts "${opts}" opt; do
    case $opt in
	u)  url=$OPTARG;;
	k)  key=$OPTARG;;
	\?) echo "Invalid option: -$OPTARG" >&2
	    usage;;
	:)  echo "Option -$OPTARG requires an argument." >&2
            usage;;
    esac
done

echo "[INFO]: Using URL ${url}/${key}"

gst-launch-1.0 -v v4l2src device=/dev/video0 \
! video/x-raw,width=640,height=480,framerate=30/1 \
! videoflip video-direction=180  \
! x264enc speed-preset=ultrafast \
! video/x-h264,stream-format=byte-stream \
! h264parse \
! queue \
! mux.   audiotestsrc freq=1 \
! audio/x-raw,rate=44100,channels=2 \
! voaacenc bitrate=128000 \
! audio/mpeg,mpegversion=4,stream-format=raw \
! queue \
! mux.   flvmux streamable=true name=mux \
! rtmpsink location=$url/$key
