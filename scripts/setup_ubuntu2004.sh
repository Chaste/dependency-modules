#!/bin/bash

# Modified dependencies script from chaste-docker: https://github.com/Chaste/chaste-docker
export DEBIAN_FRONTEND=noninteractive

apt-get update && \
apt-get install -y --no-install-recommends \
apt-utils \
apt-transport-https \
ca-certificates \
gnupg \
openssl

echo "deb http://www.cs.ox.ac.uk/chaste/ubuntu focal/" > /etc/apt/sources.list.d/chaste.list
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 422C4D99

apt-get update && \
apt-get install -y --no-install-recommends \
chaste-dependencies

apt-get install -y --no-install-recommends \
cmake \
cmake-curses-gui \
scons \
python3-dev \
python3-venv \
python3-pip \
python3-setuptools \
python2 \
libffi-dev \
doxygen \
git \
patch \
curl \
wget \
rsync \
valgrind \
libgoogle-perftools-dev \
libvtk7-dev \
graphviz \
gnuplot \
mencoder \
mplayer \
"libpetsc-real*-dbg" \
hdf5-tools \
openssh-client \
environment-modules

source /etc/profile.d/modules.sh

update-alternatives --install /usr/bin/vtk vtk /usr/bin/vtk7 7
update-alternatives --install /usr/bin/python python /usr/bin/python3 1
update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

pip install --upgrade pip
pip install texttest

export TEXTTEST_HOME=/usr/local/bin/texttest
