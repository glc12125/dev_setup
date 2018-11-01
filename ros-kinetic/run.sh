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

local_dev=$HOME/Development/rosindigo_dev
if [ ! -d $local_dev ]; then
	mkdir -p $local_dev
fi

docker volume create --driver local --opt type=none --opt device=$local_dev --opt o=bind rosindigo_dev

xhost + # Allow any connections to X server
# Run the container with shared X11
docker run \
  --privileged \
  --net=host \
  -e SHELL \
  -e DISPLAY \
  -e DOCKER=1 \
  -v rosindigo_dev:"/home/developer/Development:rw" \
  -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  -v /dev/bus/usb:/dev/bus/usb \
  -v /dev/input:/dev/input \
  -it $1 $SHELL
