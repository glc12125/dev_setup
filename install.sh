#!/bin/bash
# yavide installation script

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
        SYSTEM_PACKAGE_SET="build-essential checkinstall cmake pkg-config yasm libtiff5-dev libjpeg-dev libjasper-dev wget libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev python-dev python-numpy libtbb-dev libqt4-dev libgtk2.0-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils ffmpeg libeigen3-dev libglew-dev libusb-1.0-0-dev libpng12-dev libtiff5-dev libopenexr-dev doxygen libboost-all-dev libflann1.8 libflann-dev prelink execstack libglew-dev libglm-dev libsoil-dev freeglut3-dev libxmu-dev libxi-dev libpng++-dev autoconf automake libtool curl make g++ unzip"
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


#####################################################################################################
# Start the installation
#####################################################################################################

echo "$passwd" | sudo -S mkdir download && cd download

# Install opencv 3.2
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing opencv 3.4 ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S mkdir -p $DEV_INSTALL_DIR_DEFAULT/download
cd $DEV_INSTALL_DIR_DEFAULT/download
echo "$passwd" | sudo -S wget https://github.com/opencv/opencv/archive/3.4.0.zip -O opencv3.4.zip
echo "$passwd" | sudo -S unzip opencv3.4.zip && cd opencv-3.4.0
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo -S cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D BUILD_EXAMPLES=ON -D WITH_QT=ON -D WITH_OPENGL=ON ..
echo "$passwd" | sudo -S make -j8
echo "$passwd" | sudo -S make install
echo "$passwd" | sudo -S /bin/bash -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
echo "$passwd" | sudo -S ldconfig
echo "$passwd" | sudo -S execstack -c /usr/local/lib/*opencv*.so*
cd ../../

# Install GLFW
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing GLFW ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S git clone https://github.com/glfw/glfw && cd glfw
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo -S cmake ..
echo "$passwd" | sudo -S make -j8
echo "$passwd" | sudo -S make install
cd ../../

# Install libuvc
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing libuvc ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S git clone https://github.com/ktossell/libuvc && cd libuvc
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo -S cmake ..
echo "$passwd" | sudo -S make -j8
echo "$passwd" | sudo -S make install
cd ../../

# Install Pangolin
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing Pangolin ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S git clone https://github.com/stevenlovegrove/Pangolin.git && cd Pangolin
echo "$passwd" | sudo -S git checkout cad23ac468d202d371105676707ff5e217610008 # due to issue reported in https://github.com/stevenlovegrove/Pangolin/issues/268
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo sudo sh -c 'echo "" > ../test/log/CMakeLists.txt'
echo "$passwd" | sudo -S cmake ..
echo "$passwd" | sudo -S make -j8
echo "$passwd" | sudo -S make install
cd ../../

# Install libuvc
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing OctoMap ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S git clone git://github.com/OctoMap/octomap.git && cd octomap
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo -S cmake ..
echo "$passwd" | sudo -S make -j8
echo "$passwd" | sudo -S make install
cd ../../

# Install VTK (For pcl visualization)
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing vtk (For pcl visualization) ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S wget http://www.vtk.org/files/release/7.1/VTK-7.1.0.tar.gz
echo "$passwd" | sudo -S tar -xf VTK-7.1.0.tar.gz && cd VTK-7.1.0
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo -S cmake ..
echo "$passwd" | sudo -S make -j8
echo "$passwd" | sudo -S make install
cd ../../

# Install pcl
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing pcl 1.8 ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S wget https://github.com/PointCloudLibrary/pcl/archive/pcl-1.8.0.tar.gz
pwd
echo "$passwd" | sudo -S tar -xf pcl-1.8.0.tar.gz && cd pcl-pcl-1.8.0
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo -S cmake ..
echo "$passwd" | sudo -S make -j8
echo "$passwd" | sudo -S make install
cd ../../

# Install gflags
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing gflags 2.2.1 ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S wget https://github.com/gflags/gflags/archive/v2.2.1.zip
pwd
echo "$passwd" | sudo -S unzip v2.2.1.zip && cd gflags-2.2.1/doc 
echo "$passwd" | sudo -S wget https://github.com/gflags/gflags/blob/679df49798e2d9766975399baf063446e0957bba/index.html && cd ..
echo "$passwd" | sudo -S mkdir build && cd build
echo "$passwd" | sudo -S cmake -DBUILD_SHARED_LIBS=ON ..
echo "$passwd" | sudo -S make -j8
echo "$passwd" | sudo -S make install
cd ../../

# Install glog
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing glog 0.3.5 ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S wget https://github.com/google/glog/archive/v0.3.5.zip
pwd
echo "$passwd" | sudo -S unzip v0.3.5.zip && cd glog-0.3.5
echo "$passwd" | sudo -S export LDFLAGS='-L/usr/local/lib'
echo "$passwd" | sudo -S ./configure --includedir=/usr/local/include/gflags
echo "$passwd" | sudo -S make -j8
echo "$passwd" | sudo -S make install
cd ../../

# Install protobuf 3.5.1
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing protobuf 3.5.1 ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S wget https://github.com/protocolbuffers/protobuf/releases/download/v3.5.1/protobuf-cpp-3.5.1.zip
pwd
echo "$passwd" | sudo -S unzip protobuf-cpp-3.5.1.zip && cd protobuf-3.5.1
echo "$passwd" | sudo -S ./configure 
echo "$passwd" | sudo -S make
echo "$passwd" | sudo -S make check
echo "$passwd" | sudo -S make install
echo "$passwd" | sudo -S ldconfig

cd ../../../
echo "$passwd" | sudo -S rm -r download
