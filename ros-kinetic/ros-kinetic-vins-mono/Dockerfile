FROM ros:kinetic

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell

# Basic Utilities
RUN apt-get -y update
RUN apt-get install -y zsh screen tree sudo ssh vim vim-gtk synaptic dialog apt-utils

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

USER developer

# Latest X11 / mesa GL
RUN sudo apt-get install -y     \
  xserver-xorg-dev-lts-wily     \
  libegl1-mesa-dev-lts-wily     \
  libgl1-mesa-dev-lts-wily      \
  libgbm-dev-lts-wily           \
  mesa-common-dev-lts-wily      \
  libgles2-mesa-lts-wily        \
  libwayland-egl1-mesa-lts-wily \
  module-init-tools             \
  mesa-utils                    \
  binutils
#  libopenvg1-mesa               \

# The ROS-desktop
RUN sudo apt-get install -y ros-kinetic-desktop-full

# Dependencies required to build rviz
RUN sudo apt-get install -y                                      \
  qt4-dev-tools                                                  \
  libqt5core5a libqt5dbus5 libqt5gui5 libwayland-client0         \
  libwayland-server0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
  libxcb-render-util0 libxcb-util0-dev libxcb-xkb1 libxkbcommon-x11-0\
  libxkbcommon0                     


# Additional development tools
RUN sudo apt-get install -y x11-apps python-pip build-essential
RUN sudo pip install catkin_tools

# Install Nvidia driver, the same version as the host machine
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

RUN sudo git clone https://github.com/glc12125/dev_setup.git
RUN cd dev_setup/ros-kinetic && bash ros_install.sh

#Install source code specific dependencies

#Install Ceres and dependencies
#remove ubuntu-xboxdrv as it is causing errors
RUN sudo apt-get purge -y xboxdrv
#dependencies
RUN sudo apt-get install -y \
    libgoogle-glog-dev \
    libatlas-base-dev \
    libeigen3-dev \
    libsuitesparse-dev
RUN sudo add-apt-repository -y ppa:bzindovic/suitesparse-bugfix-1319687
#RUN sudo apt-get update -y
RUN sudo apt-get install -y libsuitesparse-dev
#Ceres
RUN sudo mkdir -p /tmp/ceres/
WORKDIR /tmp/ceres/
RUN sudo wget http://ceres-solver.org/ceres-solver-1.14.0.tar.gz \
    && sudo tar zxf ceres-solver-1.14.0.tar.gz \
    && sudo mkdir -p /tmp/ceres/ceres-bin \ 
    && cd /tmp/ceres/ceres-bin \
    && sudo cmake ../ceres-solver-1.14.0 \
    && sudo make -j3 \
    && make test \
    && sudo make install

#install python3 environment
RUN sudo apt install -y python3-pip
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade pip setuptools
RUN sudo apt-get install -y spyder3
RUN sudo apt install -y firefox
RUN pip3 install --upgrade --user jupyterlab
RUN pip3 install --upgrade --user notebook

#python packages
RUN pip3 install --upgrade scipy-stack
RUN pip3 install --user --upgrade rospkg catkin_pkg
#

#finalise with python packages from Duncan's work environment
#ADD requirements.txt
#RUN pip-3.3 install -r requirements.txt


# Switch to the workspace
WORKDIR ${workspace}
