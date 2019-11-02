#!/usr/bin/env bash

# Check args
if [ "$#" -ne 1 ]; then
  echo "usage: ./run_container.sh CONTAINER_ID"
  return 1
fi

docker exec -it -e DISPLAY $1 $SHELL