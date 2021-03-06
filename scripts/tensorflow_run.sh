# enable x server on host for open access
# -v "/tmp/.X11-unix:/tmp/.X11-unix:rw"
xhost +

local_dev=$HOME/Development/
if [ ! -d $local_dev ]; then
    mkdir -p $local_dev
fi

external_data_dir=/media/liangchuan/Samsung_T5/data/

# X Error: BadAccess (attempt to access private resource denied) : QT_X11_NO_MITSHM=1
docker run \
    --runtime=nvidia \
    --env QT_X11_NO_MITSHM=1 \
    --privileged \
    --ipc=host \
    -e SHELL \
    -e DISPLAY \
    -e DOCKER=1 \
    -v /dev/video0:/dev/video0 \
    -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -it \
    -p 8888:8888 \
    -w /Development/ \
    -v $local_dev:/Development \
    -v $external_data_dir:/Development/external_data \
    -e HOST_PERMS="$(id -u):$(id -g)" tensorflow/tensorflow:1.10.1-devel-gpu-py3 bash
