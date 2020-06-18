FROM pytorch/pytorch:latest

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

#remove ubuntu-xboxdrv as it is causing errors
RUN sudo apt-get purge -y xboxdrv

#Install pip3
RUN sudo apt-get install python3-pip

#Install opencv for python
RUN sudo apt-get install -y libopencv-dev
RUN pip3 install --user --upgrade opencv-python
RUN pip3 install --user --upgrade scipy-stack
RUN pip3 install --user --upgrade scikit-learn


# Switch to the workspace
WORKDIR ${workspace}

