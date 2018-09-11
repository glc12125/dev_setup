FROM ros:indigo

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell

# Basic Utilities
RUN apt-get -y update && apt-get install -y zsh screen tree sudo ssh synaptic

# Latest X11 / mesa GL
RUN apt-get install -y          \
  xserver-xorg-dev-lts-wily     \
  libegl1-mesa-dev-lts-wily     \
  libgl1-mesa-dev-lts-wily      \
  libgbm-dev-lts-wily           \
  mesa-common-dev-lts-wily      \
  libgles2-mesa-lts-wily        \
  libwayland-egl1-mesa-lts-wily \
  libopenvg1-mesa

# The ROS-desktop
RUN apt-get install -y ros-indigo-desktop-full

# Dependencies required to build rviz
RUN apt-get install -y                                           \
  qt4-dev-tools                                                  \
  libqt5core5a libqt5dbus5 libqt5gui5 libwayland-client0         \
  libwayland-server0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
  libxcb-render-util0 libxcb-util0 libxcb-xkb1 libxkbcommon-x11-0\
  libxkbcommon0

# Get rosinstall and some additional dependencies for wilselby
RUN apt-get -y install python-rosinstall          \
                       ros-indigo-moveit          \
                       ros-indigo-move-base       \
                       ros-indigo-octomap-msgs    \
                       ros-indigo-joy             \
                       ros-indigo-geodesy         \
                       ros-indigo-octomap-ros     \
                       libsdformat1               \
                       gazebo2                    \
                       unzip                      \
                       dialog                     \
                       apt-utils

# Install mavros but from shadow repo to get latest version earlier
RUN sh -c 'echo "deb http://packages.ros.org/ros-shadow-fixed/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-shadow.list'
RUN apt-get update
RUN apt-get -y install ros-indigo-mavros \
               ros-indigo-mavros-extras


# Additional development tools
RUN apt-get install -y x11-apps python-pip build-essential
RUN pip install catkin_tools

# Clean up
RUN apt-get -y autoremove

# Make SSH available
EXPOSE 22

# Mount the user's home directory
VOLUME "${home}"

# Clone user into docker image and set up X11 sharing 
RUN \
  echo "${user}:x:${uid}:${uid}:${user},,,:${home}:${shell}" >> /etc/passwd && \
  echo "${user}:x:${uid}:" >> /etc/group && \
  echo "${user} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${user}" && \
  chmod 0440 "/etc/sudoers.d/${user}"
# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1

# Switch to the workspace
WORKDIR ${workspace}
