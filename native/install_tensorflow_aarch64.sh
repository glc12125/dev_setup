CURRENT_USER=`whoami`
echo -n "Enter the password for $CURRENT_USER: "
stty_orig=`stty -g` # save original terminal setting.
stty -echo          # turn-off echoing.
read passwd         # read the password

echo "----------------------------------------------------------------------------"
echo "Installing bazel 0.19.2 ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S wget https://github.com/bazelbuild/bazel/releases/download/0.19.2/bazel-0.19.2-dist.zip -O bazel-0.19.2-dist.zip
echo "$passwd" | sudo -S apt-get -y install build-essential openjdk-8-jdk python zip unzip python-pip gfortran
echo "$passwd" | sudo -S pip install numpy keras mock
echo "$passwd" | sudo -S mkdir bazel-0.19.2-dist && mv bazel-0.19.2-dist.zip bazel-0.19.2-dist && cd bazel-0.19.2-dist
echo "$passwd" | sudo -S unzip bazel-0.19.2-dist.zip
echo "$passwd" | sudo -S bash compile
echo "$passwd" | sudo -S ln -s output/bazel /usr/local/bin/bazel
echo "$passwd" | sudo -S cd ../
echo "$passwd" | sudo -S git clone https://github.com/tensorflow/tensorflow.git
echo "$passwd" | sudo -S cd tensorflow
echo "$passwd" | sudo -S git checkout r1.13


# You need to patch the code following this pull request
# https://github.com/Rachelmorrell/tensorflow/commit/ced36f6006918e5e9f9a913991b4ff943b4a8915
# otherwise, there will be aws related compiling error

echo "$passwd" | sudo -S ./configure

#                                   You should fill in the fields like the example below
#WARNING: --batch mode is deprecated. Please instead explicitly shut down your Bazel server using the command "bazel shutdown".
#You have bazel 0.19.2- (@non-git) installed.
#Please specify the location of python. [Default is /usr/bin/python]:
#
#Found possible Python library paths:
#  /usr/local/lib/python2.7/dist-packages
#  /usr/lib/python2.7/dist-packages
#Please input the desired Python library path to use.  Default is [/usr/local/lib/python2.7/dist-packages]
#
#Do you wish to build TensorFlow with XLA JIT support? [Y/n]: 
#XLA JIT support will be enabled for TensorFlow.
#
#Do you wish to build TensorFlow with OpenCL SYCL support? [y/N]: 
#No OpenCL SYCL support will be enabled for TensorFlow.
#
#Do you wish to build TensorFlow with ROCm support? [y/N]: 
#No ROCm support will be enabled for TensorFlow.
#
#Do you wish to build TensorFlow with CUDA support? [y/N]: N
#No CUDA support will be enabled for TensorFlow.
#
#Do you wish to download a fresh release of clang? (Experimental) [y/N]: 
#Clang will not be downloaded.
#
#Do you wish to build TensorFlow with MPI support? [y/N]: 
#No MPI support will be enabled for TensorFlow.
#
#Please specify optimization flags to use during compilation when bazel option "--config=opt" is specified [Default is -march=native -Wno-sign-compare]: #
#
#Would you like to interactively configure ./WORKSPACE for Android builds? [y/N]: N
#Not configuring the WORKSPACE for Android builds.
#
#Preconfigured Bazel build configs. You can use any of the below by adding "--config=<>" to your build command. See .bazelrc for more details.
#	--config=mkl         	# Build with MKL support.
#	--config=monolithic  	# Config for mostly static monolithic build.
#	--config=gdr         	# Build with GDR support.
#	--config=verbs       	# Build with libverbs support.
#	--config=ngraph      	# Build with Intel nGraph support.
#	--config=dynamic_kernels	# (Experimental) Build kernels into separate shared objects.
#Preconfigured Bazel build configs to DISABLE default on features:
#	--config=noaws       	# Disable AWS S3 filesystem support.
#	--config=nogcp       	# Disable GCP support.
#	--config=nohdfs      	# Disable HDFS support.
#	--config=noignite    	# Disable Apacha Ignite support.
#	--config=nokafka     	# Disable Apache Kafka support.
#	--config=nonccl      	# Disable NVIDIA NCCL support.
#Configuration finished

echo "$passwd" | sudo -S bazel build --config=opt --worker_max_instances=1 --jobs=0 //tensorflow/tools/pip_package:build_pip_package
