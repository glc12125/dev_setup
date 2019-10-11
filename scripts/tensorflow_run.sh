xhost +
docker run \
    --runtime=nvidia \
    --privileged \
    -e SHELL \
    -e DISPLAY \
    -e DOCKER=1 \
    -v /dev/video0:/dev/video0 \
    -it \
    -p 8888:8888 \
    -w /Development/ \
    -v /home/liangchuan/Development:/Development \
    -e HOST_PERMS="$(id -u):$(id -g)" tensorflow/tensorflow:1.10.1-devel-gpu-py3 bash