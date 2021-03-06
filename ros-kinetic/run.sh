#!/usr/bin/env bash

# Check args
if [ "$#" -ne 1 ]; then
  echo "usage: ./run.sh IMAGE_NAME"
  return 1
fi

# Get this script's path
pushd `dirname $0` > /dev/null
popd > /dev/null

set -e

local_dev=$HOME/Development
if [ ! -d $local_dev ]; then
	mkdir -p $local_dev
fi

#docker volume create --driver local --opt type=none --opt device=$local_dev --opt o=bind roskinetic_dev

xhost + # Allow any connections to X server
# Run the container with shared X11
docker run \
  --privileged \
  -e SHELL \
  -e DISPLAY \
  -e DOCKER=1 \
  -w /Development/ \
  -p 8888:8888 \
  -v $local_dev:/Development \
  -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  -v /dev/video0:/dev/video0 \
  -v /dev/bus/usb:/dev/bus/usb \
  -v /dev/input:/dev/input \
  -it $1 $SHELL
