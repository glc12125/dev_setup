#!/bin/bash
# dev environment installation script

#####################################################################################################
# Variables
#####################################################################################################
SYSTEM_PACKAGE_MANAGER=""
SYSTEM_PACKAGE_TYPE=""
SYSTEM_PACKAGE_SET=""
ROS_PACKAGE_SET="ros-indigo-desktop-full"
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
        SYSTEM_PACKAGE_SET="python-rosinstall python-rosinstall-generator python-wstool build-essential checkinstall pkg-config yasm wget libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine2-dev python-dev python-numpy libusb-1.0-0-dev doxygen libboost-all-dev autoconf automake libtool curl make g++ unzip libhdf5-dev libwebp-dev software-properties-common"
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
echo "$passwd" | sudo -S echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc
source ~/.bashrc


# Upgrade cmake to 3.x
echo "$passwd" | sudo -S apt-get install software-properties-common
echo "$passwd" | sudo -S add-apt-repository ppa:george-edison55/cmake-3.x
echo "$passwd" | sudo -S apt-get update
echo "$passwd" | sudo -S apt-get install cmake



# Install mavros but from shadow repo to get latest version earlier
echo "$passwd" | sudo -S sh -c 'echo "deb http://packages.ros.org/ros-shadow-fixed/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-shadow.list'
echo "$passwd" | sudo -S apt-get update
echo "$passwd" | sudo -S apt-get -y install ros-indigo-mavros \
                                    ros-indigo-mavros-extras

# Get rosinstall and some additional dependencies for wilselby
echo "$passwd" | sudo -S apt-get -y install python-rosinstall          \
                                            ros-indigo-moveit          \
                                            ros-indigo-move-base       \
                                            ros-indigo-octomap-msgs    \
                                            ros-indigo-joy             \
                                            ros-indigo-geodesy         \
                                            ros-indigo-ros-control     \
                                            ros-indigo-octomap-ros     \
                                            ros-indigo-ecl-threads     \
                                            libsdformat1               \
                                            gazebo2                    \
                                            unzip                 



#####################################################################################################
# Start the installation from source code
#####################################################################################################
DEV_INSTALL_DIR_DEFAULT="/opt/tmp"
LIB_INSTALL_PATH="/usr/local"
echo "$passwd" | sudo -S mkdir $LIB_INSTALL_PATH

# Install opencv 3.2
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing opencv 3.2.0 and opencv_contrib 3.2.0 ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S mkdir -p $DEV_INSTALL_DIR_DEFAULT/download
cd $DEV_INSTALL_DIR_DEFAULT/download
echo "$passwd" | sudo -S wget https://github.com/opencv/opencv/archive/3.2.0.zip -O opencv3.2.zip
echo "$passwd" | sudo -S wget https://github.com/opencv/opencv_contrib/archive/3.2.0.zip -O opencv_contrib-3.2.0.zip
echo "$passwd" | sudo -S unzip opencv3.2.zip
echo "$passwd" | sudo -S unzip opencv_contrib-3.2.0.zip && cd opencv-3.2.0
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo -S cmake -D CMAKE_BUILD_TYPE=RELEASE -D BUILD_SHARED_LIBS=OFF -D CMAKE_INSTALL_PREFIX=$LIB_INSTALL_PATH -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D INSTALL_C_EXAMPLES=OFF -D INSTALL_PYTHON_EXAMPLES=OFF -D BUILD_EXAMPLES=OFF -D WITH_QT=ON -D WITH_OPENGL=ON -D WITH_VTK=ON -D WITH_CUDA=OFF -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-3.2.0/modules ..
echo "$passwd" | sudo -S make -j$(nproc)
echo "$passwd" | sudo -S make install
echo "$passwd" | sudo -S /bin/bash -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
echo "$passwd" | sudo -S ldconfig
echo "$passwd" | sudo -S execstack -c /usr/local/lib/*opencv*.so*


# Install pcl
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing pcl 1.8 ..."
echo "----------------------------------------------------------------------------"
cd $DEV_INSTALL_DIR_DEFAULT/download
echo "$passwd" | sudo -S wget https://github.com/PointCloudLibrary/pcl/archive/pcl-1.8.0.tar.gz
echo "$passwd" | sudo -S tar -xf pcl-1.8.0.tar.gz && cd pcl-pcl-1.8.0
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo -S cmake -D CMAKE_INSTALL_PREFIX=$LIB_INSTALL_PATH ..
echo "$passwd" | sudo -S make -j$(nproc)
echo "$passwd" | sudo -S make install



# get development repo
DEV_WORKSPACE=/home/$CURRENT_USER/Development
echo "$passwd" | sudo -S mkdir -p $DEV_WORKSPACE
cd $DEV_WORKSPACE


# The following steps have to be mannual for confidentiality and security reasons
#
#echo "$passwd" | sudo -S git clone https://github.com/glc12125/mVSLAM.git

#DEV_MAIN_PROJECT_DIR="${DEV_WORKSPACE}/mVSLAM"
#cd $DEV_MAIN_PROJECT_DIR
#echo "$passwd" | sudo -S git checkout fast-plan
#echo "$passwd" | sudo -S ./updateGitSubmodule.sh
#sudo chown 1000:1000 -R $DEV_WORKSPACE
#ROS_WORKSPACE="${DEV_WORKSPACE}/mVSLAM/apps/ros_catkin_workspace"



#echo -e "\n"
#echo "----------------------------------------------------------------------------"
#echo "Compiling ROS workspace via script ..."
#cd $ROS_WORKSPACE
#pwd
#cd $DEV_MAIN_PROJECT_DIR
#echo "$passwd" | sudo -S ./build.sh
#print_green "Done !"

# This is necessary to make sure all changes can be picked up
#sh -c "echo 'source $ROS_WORKSPACE/devel/setup.bash' >> ~/.bashrc"
#source ~/.bashrc


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


echo "$passwd" | sudo -S rm -r $DEV_INSTALL_DIR_DEFAULT/download