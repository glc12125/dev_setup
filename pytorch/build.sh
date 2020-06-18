#!/usr/bin/env bash

# Check args
if [ "$#" -ne 1 ]; then
  echo "usage: ./build.sh IMAGE_NAME"
  return 1
fi


fileFound=false
while [[ "$fileFound" = false ]]
do
    read -p "Enter the NVIDIA driver run file (Default NVIDIA-Linux-x86_64-384.130.run): " runFile # Ask the user to enter a run file
    if [ "$runFile" = '' ]; then
        runFile="../nvidia_drivers/NVIDIA-Linux-x86_64-384.130.run"
    fi
    if [ ! -f $runFile ]; then
        echo "Run file not found!"
        fileFound=false
    else
        fileFound=true
    fi
done 

start_time=`date +%s`

NVIDIA_DRIVER=$runFile  # path to nvidia driver

echo "Nvidia drvier to be installed: $NVIDIA_DRIVER"
cp ${NVIDIA_DRIVER} NVIDIA-DRIVER.run

# Get this script's path
pushd `dirname $0` > /dev/null
DEV_PATH=/home/developer/Development
popd > /dev/null

# Build the docker image
docker build\
  --build-arg user=$USER\
  --build-arg uid=$UID\
  --build-arg home=$HOME\
  --build-arg workspace=$DEV_PATH\
  --build-arg shell=$SHELL\
  -t $1 .

echo Execution time is $(expr `date +%s` - $start_time) s