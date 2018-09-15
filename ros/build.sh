#!/usr/bin/env bash

# Check args
if [ "$#" -ne 1 ]; then
  echo "usage: ./build.sh IMAGE_NAME"
  return 1
fi


fileFound=false
while [[ '$fileFound' = false ]] # While string is empty...
do
    read -p "Enter the NVIDIA driver run file: " runFile # Ask the user to enter a run file
    if [ '$runFile' = '' ]; then
		runFile="NVIDIA-Linux-x86_64-384.130.run"
	fi
    if [ ! -f $runFile ]; then
    	echo "Run file not found!"
    	fileFound=false
    else
    	fileFound=true
	fi
done 

NVIDIA_DRIVER=$runFile  # path to nvidia driver

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
