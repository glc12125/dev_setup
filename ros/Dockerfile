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
RUN rosdep init
RUN rosdep update
RUN sh -c 'echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc'

# Dependencies required to build rviz
RUN apt-get install -y                                           \
  qt4-dev-tools                                                  \
  libqt5core5a libqt5dbus5 libqt5gui5 libwayland-client0         \
  libwayland-server0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
  libxcb-render-util0 libxcb-util0 libxcb-xkb1 libxkbcommon-x11-0\
  libxkbcommon0

# Get rosinstall and some additional dependencies for wilselby
RUN apt-get -y install python-rosinstall          \
                       ros-indigo-octomap-msgs    \
                       ros-indigo-joy             \
                       ros-indigo-geodesy         \
                       ros-indigo-octomap-ros     \
                       libsdformat1               \
                       gazebo2                    \
                       unzip

# Install mavros but from shadow repo to get latest version earlier
RUN sh -c 'echo "deb http://packages.ros.org/ros-shadow-fixed/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-shadow.list'
RUN apt-get update
RUN apt-get -y install ros-indigo-mavros \
               ros-indigo-mavros-extras


# Additional development tools
RUN apt-get install -y x11-apps python-pip build-essential
RUN pip install catkin_tools

# Make SSH available
EXPOSE 22

# Mount the user's home directory
VOLUME "${home}"

# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1

# Set up catkin workspace
ENV ROS_WORKSPACE="${workspace}/ros"
RUN mkdir -p ROS_WORKSPACE
RUN mkdir -p $ROS_WORKSPACE/src
RUN cd $ROS_WORKSPACE/src
RUN catkin_init_workspace
RUN cd $ROS_WORKSPACE
RUN catkin_make
RUN sh -c "echo 'source $ROS_WORKSPACE/devel/setup.bash' >> ~/.bashrc"
RUN source ~/.bashrc

# Switch to the workspace
WORKDIR ${workspace}
