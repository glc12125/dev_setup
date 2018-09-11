FROM ros:indigo

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell

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

# Basic Utilities
RUN sudo apt-get -y update
RUN sudo apt-get install -y zsh screen tree sudo ssh synaptic dialog apt-utils

# Latest X11 / mesa GL
RUN sudo apt-get install -y          \
  xserver-xorg-dev-lts-wily     \
  libegl1-mesa-dev-lts-wily     \
  libgl1-mesa-dev-lts-wily      \
  libgbm-dev-lts-wily           \
  mesa-common-dev-lts-wily      \
  libgles2-mesa-lts-wily        \
  libwayland-egl1-mesa-lts-wily \
  libopenvg1-mesa

# The ROS-desktop
RUN sudo apt-get install -y ros-indigo-desktop-full

# Dependencies required to build rviz
RUN sudo apt-get install -y                                           \
  qt4-dev-tools                                                  \
  libqt5core5a libqt5dbus5 libqt5gui5 libwayland-client0         \
  libwayland-server0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
  libxcb-render-util0 libxcb-util0 libxcb-xkb1 libxkbcommon-x11-0\
  libxkbcommon0

# Get rosinstall and some additional dependencies for wilselby
RUN sudo apt-get -y install python-rosinstall          \
                       ros-indigo-moveit          \
                       ros-indigo-move-base       \
                       ros-indigo-octomap-msgs    \
                       ros-indigo-joy             \
                       ros-indigo-geodesy         \
                       ros-indigo-octomap-ros     \
                       libsdformat1               \
                       gazebo2                    \
                       unzip                      

# Install mavros but from shadow repo to get latest version earlier
RUN sh -c 'echo "deb http://packages.ros.org/ros-shadow-fixed/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-shadow.list'
RUN sudo apt-get update
RUN sudo apt-get -y install ros-indigo-mavros \
               ros-indigo-mavros-extras


# Additional development tools
RUN sudo apt-get install -y x11-apps python-pip build-essential
RUN sudo pip install catkin_tools

# Clean up
RUN sudo apt-get -y autoremove

# Make SSH available
EXPOSE 22

ENV HOME /home/developer

# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1

# Switch to the workspace
WORKDIR ${workspace}
