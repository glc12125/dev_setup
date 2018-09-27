#!/bin/bash
# dev environment installation script

#####################################################################################################
# Variables
#####################################################################################################
SYSTEM_PACKAGE_MANAGER=""
SYSTEM_PACKAGE_TYPE=""
SYSTEM_PACKAGE_SET=""
ROS_PACKAGE_SET="ros-kinetic-desktop-full"
DEV_INSTALL_DIR_DEFAULT="/opt/tmp"
#####################################################################################################
# Helper functions
#####################################################################################################
guess_system_package_manager(){
    if [ "`which apt-get`" != "" ]; then
        SYSTEM_PACKAGE_MANAGER="apt-get"
        SYSTEM_PACKAGE_TYPE="deb"
        SYSTEM_PACKAGE_MANAGER_INSTALL="apt-get -y install"
        SYSTEM_PACKAGE_MANAGER_UPDATE="apt-get update"
    fi

    if [ $SYSTEM_PACKAGE_TYPE == "deb" ]; then
        SYSTEM_PACKAGE_SET="python-rosinstall python-rosinstall-generator python-wstool build-essential checkinstall cmake pkg-config yasm wget libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine2-dev python-dev python-numpy libusb-1.0-0-dev doxygen libboost-all-dev autoconf automake libtool curl make g++ unzip software-properties-common"
    fi
}

print_usage(){
    echo -e "Usage: './ros_install.sh'"
    echo -e "There are no args supported, only Ubuntu 16.04 is supported."
}

print_green(){
    echo -e "\e[32m$1\e[39m"
}


#####################################################################################################
# Make sure the correct versions of OS is supported
#####################################################################################################
if [ $# -eq 0 ]; then
    echo "Installing for Ubuntu 16.04 by default."
else
    echo "Invalid number of arguments!"
    print_usage
    echo "Exiting ..."
    exit
fi

#####################################################################################################
# Identify the system package manager
#####################################################################################################
guess_system_package_manager
if [ -z $SYSTEM_PACKAGE_MANAGER ]; then
    echo "Identifying the system package manager failed. Currently supported ones are:
    'apt-get'"
fi
echo "System package manager: '"$SYSTEM_PACKAGE_MANAGER"'"
echo "System package type: '"$SYSTEM_PACKAGE_TYPE"'"

#####################################################################################################
# Root password needed for some operations
#####################################################################################################
CURRENT_USER=`whoami`
echo -n "Enter the password for $CURRENT_USER: "
stty_orig=`stty -g` # save original terminal setting.
stty -echo          # turn-off echoing.
read passwd         # read the password
stty $stty_orig     # restore terminal setting.

#####################################################################################################
# Install dependencies for Kinetic
#####################################################################################################
#echo "$passwd" | sudo -S sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
#echo "$passwd" | sudo -S apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
echo "$passwd" | sudo -S $SYSTEM_PACKAGE_MANAGER_UPDATE
echo "$passwd" | sudo -S $SYSTEM_PACKAGE_MANAGER_INSTALL $SYSTEM_PACKAGE_SET
echo "$passwd" | sudo -S $SYSTEM_PACKAGE_MANAGER_INSTALL $ROS_PACKAGE_SET
echo "$passwd" | sudo -S rosdep init
echo "$passwd" | sudo -S rosdep fix-permissions
rosdep update
echo "$passwd" | sudo -S echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
source ~/.bashrc


# Install mavros but from shadow repo to get latest version earlier
echo "$passwd" | sudo -S sh -c 'echo "deb http://packages.ros.org/ros-shadow-fixed/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-shadow.list'
echo "$passwd" | sudo -S apt-get update
echo "$passwd" | sudo -S apt-get -y install ros-kinetic-mavros \
                                    ros-kinetic-mavros-extras

# Get rosinstall and some additional dependencies for wilselby
echo "$passwd" | sudo -S apt-get -y install python-rosinstall          \
                                            ros-kinetic-moveit          \
                                            ros-kinetic-move-base       \
                                            ros-kinetic-octomap-msgs    \
                                            ros-kinetic-joy             \
                                            ros-kinetic-geodesy         \
                                            ros-kinetic-octomap-ros     \
                                            unzip                 

# Set up catkin workspace, note workspace is recommended to match that in build.sh for consistency
workspace=/home/$CURRENT_USER/Development
ROS_WORKSPACE="${workspace}/ros"
sudo mkdir -p ROS_WORKSPACE
sudo mkdir -p $ROS_WORKSPACE/src
sudo chown 1000:1000 -R $ROS_WORKSPACE
cd $ROS_WORKSPACE/src
catkin_init_workspace
cd $ROS_WORKSPACE
catkin_make
sh -c "echo 'source $ROS_WORKSPACE/devel/setup.bash' >> ~/.bashrc"
source ~/.bashrc
ROS_WORKSPACE="${workspace}/ros"
cd $ROS_WORKSPACE/src
pwd

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing gazebo9 ..."
echo "$passwd" | sudo -S curl -sSL http://get.gazebosim.org | sh
print_green "Done !"

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Cloning catkin_simple ..."
echo "$passwd" | sudo -S git clone https://github.com/catkin/catkin_simple.git
print_green "Done !"

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Cloning gflags_catkin ..."
echo "$passwd" | sudo -S git clone https://github.com/ethz-asl/gflags_catkin.git
print_green "Done !"

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Compiling gflags_catkin first via catkin_make ..."
ROS_WORKSPACE="${workspace}/ros"
cd $ROS_WORKSPACE
pwd
source devel/setup.bash
catkin_make

ROS_WORKSPACE="${workspace}/ros"
cd $ROS_WORKSPACE/src
pwd
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Cloning glog_catkin ..."
echo "$passwd" | sudo -S git clone https://github.com/ethz-asl/glog_catkin.git
echo "$passwd" | sudo -S cp glog_catkin/fix-unused-typedef-warning.patch .
print_green "Done !"

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Compiling glog_catkin first via catkin_make ..."
cd $ROS_WORKSPACE
pwd
source devel/setup.bash
catkin_make

ROS_WORKSPACE="${workspace}/ros"
cd $ROS_WORKSPACE/src
pwd

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Cloning mav_comm ..."
echo "$passwd" | sudo -S git clone https://github.com/PX4/mav_comm.git
print_green "Done !"

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Cloning ROS_quadrotor_simulator ..."
echo "$passwd" | sudo -S git clone https://github.com/wilselby/ROS_quadrotor_simulator
print_green "Done !"

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Cloning RotorS ..."
echo "$passwd" | sudo -S git clone https://github.com/wilselby/rotors_simulator
print_green "Done !"
echo "Installing RotorS"

cd $ROS_WORKSPACE
pwd
echo "$passwd" | sudo -S rosdep install --from-paths src --ignore-src --rosdistro kinetic -y
print_green "Done !"

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Compiling ROS workspace via catkin_make ..."
cd $ROS_WORKSPACE
pwd
source devel/setup.bash
catkin_make
print_green "Done !"

# This is necessary to make sure all changes can be picked up
source devel/setup.bash


echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Install the integrated Ubuntu Xbox driver ..."
echo "$passwd" | sudo -S apt-add-repository ppa:rael-gc/ubuntu-xboxdrv
echo "$passwd" | sudo -S apt-get update
echo "$passwd" | sudo -S apt-get install ubuntu-xboxdrv
print_green "Done !"

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Install the jstest-gtk package ..."
echo "$passwd" | sudo -S apt-get install jstest-gtk

echo -e "\n\n"
echo "----------------------------------------------------------------------------"
print_green "Installation completes"
echo -e "Please run source /home/developer/Development/ros/devel/setup.sh"
echo " before runing any ros packages"
echo "----------------------------------------------------------------------------"
