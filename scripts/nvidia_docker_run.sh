# Check args
if [ "$#" -ne 1 ]; then
  #echo "usage: ./run.sh IMAGE_NAME"
  #return 1
  echo "Using default: robok2017/dev_build:ubuntu16.04"
  IMAGE_NAME=robok2017/dev_build:ubuntu16.04
else
  IMAGE_NAME=$1
fi

# enable x server on host for open access
# -v "/tmp/.X11-unix:/tmp/.X11-unix:rw"
xhost +
# X Error: BadAccess (attempt to access private resource denied) : QT_X11_NO_MITSHM=1
docker run \
    --gpus all \
    --env QT_X11_NO_MITSHM=1 \
    --privileged \
    -e SHELL \
    -e DISPLAY \
    -e DOCKER=1 \
    -e "DISPLAY=unix$DISPLAY" \
    --device /dev/dri \
    -v /dev/video0:/dev/video0 \
    -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -it \
    -p 8888:8888 \
    -w /Development/ \
    -v /home/liangchuan/Development:/Development \
    -e HOST_PERMS="$(id -u):$(id -g)" $IMAGE_NAME bash
