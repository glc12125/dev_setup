#!/bin/bash
# dev environment installation script

#####################################################################################################
# Variables
#####################################################################################################
SYSTEM_PACKAGE_MANAGER=""
SYSTEM_PACKAGE_TYPE=""
SYSTEM_PACKAGE_SET=""
DEV_INSTALL_DIR_DEFAULT="/opt/tmp"
#####################################################################################################
# Helper functions
#####################################################################################################
guess_system_package_manager(){
    if [ "`which dnf`" != "" ]; then
        SYSTEM_PACKAGE_MANAGER="dnf"
        SYSTEM_PACKAGE_TYPE="rpm"
        SYSTEM_PACKAGE_MANAGER_INSTALL="dnf -y install"
        SYSTEM_PACKAGE_MANAGER_UPDATE="dnf --refresh check-update"
    elif [ "`which apt-get`" != "" ]; then
        SYSTEM_PACKAGE_MANAGER="apt-get"
        SYSTEM_PACKAGE_TYPE="deb"
        SYSTEM_PACKAGE_MANAGER_INSTALL="apt-get -y install"
        SYSTEM_PACKAGE_MANAGER_UPDATE="apt-get update"
    elif [ "`which zypper`" != "" ]; then
        SYSTEM_PACKAGE_MANAGER="zypper"
        SYSTEM_PACKAGE_TYPE="rpm"
        SYSTEM_PACKAGE_MANAGER_INSTALL="zypper --non-interactive install"
        SYSTEM_PACKAGE_MANAGER_UPDATE="zypper refresh"
    elif [ "`which yum`" != "" ]; then
        SYSTEM_PACKAGE_MANAGER="yum"
        SYSTEM_PACKAGE_TYPE="rpm"
        SYSTEM_PACKAGE_MANAGER_INSTALL="yum -y install"
        SYSTEM_PACKAGE_MANAGER_UPDATE="yum check-update"
    elif [ "`which pacman`" != "" ]; then
        SYSTEM_PACKAGE_MANAGER="pacman"
        SYSTEM_PACKAGE_TYPE="archpkg"
        SYSTEM_PACKAGE_MANAGER_INSTALL="pacman --noconfirm -S"
        SYSTEM_PACKAGE_MANAGER_UPDATE="pacman -Syu"
    elif [ "`which emerge`" != "" ]; then
        SYSTEM_PACKAGE_MANAGER="emerge"
        SYSTEM_PACKAGE_TYPE="ebuild"
        SYSTEM_PACKAGE_MANAGER_INSTALL="emerge"
        SYSTEM_PACKAGE_MANAGER_UPDATE="emerge --sync"
    fi

    if [ $SYSTEM_PACKAGE_TYPE == "rpm" ]; then
        SYSTEM_PACKAGE_SET="gvim ctags cscope git wget pcre-devel libyaml-devel python-pip python-devel clang-devel clang-libs"
    elif [ $SYSTEM_PACKAGE_TYPE == "deb" ]; then
        SYSTEM_PACKAGE_SET="build-essential checkinstall cmake pkg-config yasm libtiff5-dev libjpeg-dev wget libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine2-dev libv4l-dev python-dev python-numpy libtbb-dev libqt4-dev libgtk2.0-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils libeigen3-dev libglew-dev libusb-1.0-0-dev libtiff5-dev libopenexr-dev doxygen libboost-all-dev libflann-dev prelink execstack libglew-dev libglm-dev libsoil-dev freeglut3-dev libxmu-dev libxi-dev libpng++-dev autoconf automake libtool curl make g++ unzip libwebp-dev"
    elif [ $SYSTEM_PACKAGE_TYPE == "archpkg" || $SYSTEM_PACKAGE_TYPE == "ebuild" ]; then
        SYSTEM_PACKAGE_SET="gvim ctags cscope git wget pcre libyaml python-pip python clang"
    fi

}

print_usage(){
    echo -e "Usage: './install.sh'"
    echo -e "There are no args supported, only Ubuntu 16.04 is supported."
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
    'dnf', 'apt-get', 'zypper', 'yum', 'pacman', 'emerge'"
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
# Install dependencies
#####################################################################################################
echo "$passwd" | sudo -S $SYSTEM_PACKAGE_MANAGER_UPDATE
echo "$passwd" | sudo -S $SYSTEM_PACKAGE_MANAGER_INSTALL $SYSTEM_PACKAGE_SET

# Build the destination directory and copy all of the relevant files
echo "$passwd" | sudo -S mkdir -p $DEV_INSTALL_DIR_DEFAULT
cd $DEV_INSTALL_DIR_DEFAULT

#####################################################################################################
# Start the installation
#####################################################################################################

echo "$passwd" | sudo -S mkdir download && cd download
echo "$passwd" | sudo -S mkdir ~/libs

# Install opencv 3.4.5
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing opencv 3.4.5 and opencv_contrib 3.4.5 ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S wget https://github.com/opencv/opencv/archive/3.4.5.zip -O opencv3.4.5.zip
echo "$passwd" | sudo -S wget https://github.com/opencv/opencv_contrib/archive/3.4.5.zip -O opencv_contrib-3.4.5.zip
echo "$passwd" | sudo -S unzip opencv3.4.5.zip
echo "$passwd" | sudo -S unzip opencv_contrib-3.4.5.zip && cd opencv-3.4.5
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo -S cmake -D CMAKE_BUILD_TYPE=RELEASE -D BUILD_SHARED_LIBS=OFF -D CMAKE_INSTALL_PREFIX=~/libs -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D INSTALL_C_EXAMPLES=OFF -D INSTALL_PYTHON_EXAMPLES=OFF -D BUILD_EXAMPLES=OFF -D WITH_VTK=ON -D WITH_CUDA=OFF -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-3.4.5/modules ..
echo "$passwd" | sudo -S make -j$(nproc)
echo "$passwd" | sudo -S make install
echo "$passwd" | sudo -S /bin/bash -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
echo "$passwd" | sudo -S ldconfig
echo "$passwd" | sudo -S execstack -c /usr/local/lib/*opencv*.so*
cd $DEV_INSTALL_DIR_DEFAULT/download

# Install boost 1.58 static libraries
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing boost 1.58 static libraries ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.bz2
echo "$passwd" | sudo -S tar --bzip2 -xf boost_1_60_0.tar.bz2 && cd boost_1_60_0
echo "$passwd" | sudo -S ./bootstrap.sh --prefix=~/libs
echo "$passwd" | sudo -S ./b2 --prefix=~/libs link=static install
cd $DEV_INSTALL_DIR_DEFAULT/download

# Install GLFW
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing GLFW ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S git clone https://github.com/glfw/glfw && cd glfw
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo -S cmake -D CMAKE_INSTALL_PREFIX=~/libs ..
echo "$passwd" | sudo -S make -j$(nproc)
echo "$passwd" | sudo -S make install
cd $DEV_INSTALL_DIR_DEFAULT/download

# Install libuvc
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing libuvc ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S git clone https://github.com/ktossell/libuvc && cd libuvc
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo -S cmake -D CMAKE_INSTALL_PREFIX=~/libs ..
echo "$passwd" | sudo -S make -j$(nproc)
echo "$passwd" | sudo -S make install
cd $DEV_INSTALL_DIR_DEFAULT/download

cd $DEV_INSTALL_DIR_DEFAULT
echo "$passwd" | sudo -S rm -r download
