#!/bin/bash

# Modified dependencies script from chaste-docker: https://github.com/Chaste/chaste-docker
export DEBIAN_FRONTEND=noninteractive

apt-get update && \
apt-get install -y --no-install-recommends \
apt-utils \
apt-transport-https \
ca-certificates \
gnupg \
openssl \
wget \
curl \
rsync

echo "deb http://www.cs.ox.ac.uk/chaste/ubuntu focal/" > /etc/apt/sources.list.d/chaste.list
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 422C4D99

apt-get update && apt-get install -y chaste-dependencies

apt-get install -y --no-install-recommends \
python3-dev \
python3-pip \
libffi-dev \
mencoder \
mplayer \
openssh-client \
environment-modules

source /etc/profile.d/modules.sh

update-alternatives --install /usr/bin/vtk vtk /usr/bin/vtk7 7
update-alternatives --install /usr/bin/python python /usr/bin/python3 1
update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

pip install --upgrade pip
pip install texttest

export TEXTTEST_HOME=/usr/local/bin/texttest
