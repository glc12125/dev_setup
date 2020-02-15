#!/usr/bin/env bash

# Check args
if [ "$#" -ne 1 ]; then
  #echo "usage: ./run.sh IMAGE_NAME"
  #return 1
  echo "Using default: glc12125/ros-indigo-slam:lsd.N430_50"
  IMAGE_NAME=glc12125/ros-indigo-slam:lsd.N430_50
else
  IMAGE_NAME=$1
fi

# Get this script's path
pushd `dirname $0` > /dev/null
popd > /dev/null

set -e

local_dev=$HOME/Development/
if [ ! -d $local_dev ]; then
  mkdir -p $local_dev
fi

#docker volume create --driver local --opt type=none --opt device=$local_dev --opt o=bind rosindigo_dev

xhost + # Allow any connections to X server
# Run the container with shared X11
docker run \
  --privileged \
  -e SHELL \
  -e DISPLAY \
  -e DOCKER=1 \
  -w /Development/ \
  -v $local_dev:/Development \
  -v /media/robok/Samsung_T51/data:/Development/external_data \
  -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  -v /dev/bus/usb:/dev/bus/usb \
  -v /dev/input:/dev/input \
  -it $IMAGE_NAME $SHELL
