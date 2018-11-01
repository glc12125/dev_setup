# dev_setup
Instructions:
* create docker image: ./build.sh <docker_image_name>
( This will prompt to specify NVIDIA driver, please match the host machine NVIDIA driver version, otherwise GUI won't be bridged successfully)
* run docker image: ./run.sh <docker_image_name> (This will run the docker image and create a temporary container, if you want to commit the changes you made in the container, please run docker commit <container hash id> <your docker hub repo>. e.g. docker commit c3f279d17e0a  glc12125/robok_rosindigo:v1. This script will also create a shared development workspace $HOME/Development/rosindigo_dev and maps it to /home/developer/Development within docker image)
