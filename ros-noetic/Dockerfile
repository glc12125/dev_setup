FROM ros:noetic

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell

#remove interactions with installations
ENV DEBIAN_FRONTEND=noninteractive 

# Basic Utilities
RUN apt-get -y update
RUN apt-get install -y zsh screen tree sudo ssh vim vim-gtk synaptic dialog apt-utils

# set locale
RUN apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8


# Mount the user's home directory
VOLUME "${home}"

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:${shell}" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

# USER developer

# Latest X11 / mesa GL
RUN  apt-get install -y     \
  xserver-xorg-dev     \
  libegl1-mesa-dev     \
  libgl1-mesa-dev      \
  libgbm-dev           \
  mesa-common-dev      \
  libgles2-mesa        \
  libwayland-egl1-mesa \
  #module-init-tools             \
  mesa-utils                    \
  binutils
#  libopenvg1-mesa               \

# The ROS-desktop
RUN sudo apt-get install -y --no-install-recommends ros-noetic-desktop-full

# Dependencies required to build rviz
RUN sudo apt-get install -y                                      \
  libqt5core5a libqt5dbus5 libqt5gui5 libwayland-client0         \
  libwayland-server0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
  libxcb-render-util0 libxcb-util0-dev libxcb-xkb1 libxkbcommon-x11-0\
  libxkbcommon0                     

#failed to install
#RUN sudo apt-get install -y                                      \
#  qt4-dev-tools

# Additional development tools
RUN sudo apt-get install -y x11-apps python3-pip build-essential 
RUN sudo pip3 install catkin_tools

# Install Nvidia driver, the same version as the host machine
RUN sudo apt-get install -y kmod
ADD NVIDIA-DRIVER.run /tmp/NVIDIA-DRIVER.run
RUN sudo sh /tmp/NVIDIA-DRIVER.run -a -N --ui=none --no-kernel-module
RUN sudo rm /tmp/NVIDIA-DRIVER.run

# Clean up
RUN sudo apt-get -y autoremove

# Make SSH available
EXPOSE 22

ENV HOME /home/developer

# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1

# run the setup script
RUN sudo mkdir -p ${workspace} && cd ${workspace}


RUN sudo apt-get install git -y
COPY ros_install.sh ros_install.sh
RUN bash ros_install.sh

#remove ubuntu-xboxdrv as it is causing errors
RUN sudo apt-get purge -y xboxdrv



#install python3 environment
RUN sudo apt install -y python3-pip
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade pip setuptools
RUN sudo apt install -y firefox
RUN pip3 install --upgrade jupyterlab
RUN pip3 install --upgrade  notebook
RUN sudo apt update -y && \
    sudo apt install python3-pcl -y


#python packages
RUN pip3 install --upgrade scipy-stack
RUN pip3 install --upgrade rospkg catkin_pkg
RUN sudo apt install python3-opencv


# Switch to the workspace
WORKDIR ${workspace}

