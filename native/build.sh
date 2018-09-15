#!/usr/bin/env bash

# Check args
if [ "$#" -ne 1 ]; then
  echo "usage: ./build.sh IMAGE_NAME"
  return 1
fi


start_time=`date +%s`

echo -e "Downloading ubuntu bare bone image"
if [ ! -f ubuntu-xenial-core-cloudimg-amd64-root.tar.gz ]; then
  wget https://partner-images.canonical.com/core/xenial/current/ubuntu-xenial-core-cloudimg-amd64-root.tar.gz
fi
echo "Done!"

# Build the docker image
docker build -t $1 .

echo Execution time is $(expr `date +%s` - $start_time) s
