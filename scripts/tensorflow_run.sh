# enable x server on host for open access
# -v "/tmp/.X11-unix:/tmp/.X11-unix:rw"
xhost +
# X Error: BadAccess (attempt to access private resource denied) : QT_X11_NO_MITSHM=1
docker run \
    --runtime=nvidia \
    --env QT_X11_NO_MITSHM=1 \
    --privileged \
    -e SHELL \
    -e DISPLAY \
    -e DOCKER=1 \
    -v /dev/video0:/dev/video0 \
    -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -it \
    -p 8888:8888 \
    -w /Development/ \
    -v /home/liangchuan/Development:/Development \
    -e HOST_PERMS="$(id -u):$(id -g)" tensorflow/tensorflow:1.10.1-devel-gpu-py3 bash