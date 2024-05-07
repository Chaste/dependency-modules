#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

apt-get update && \
apt-get install -y --no-install-recommends \
  apt-utils \
  apt-transport-https \
  ca-certificates \
  gnupg \
  wget

apt-get update && \
apt-get install -y --no-install-recommends \
  cmake \
  cmake-curses-gui \
  doxygen \
  environment-modules \
  g++ \
  git \
  gnuplot \
  graphviz \
  hdf5-tools \
  lcov \
  libboost-serialization-dev \
  libboost-filesystem-dev \
  libboost-program-options-dev \
  libhdf5-openmpi-dev \
  libmetis-dev \
  libopenmpi-dev \
  libparmetis-dev \
  libpetsc-real3.15 \
  libpetsc-real3.15-dbg \
  libpetsc-real3.15-dev \
  libsundials-dev \
  libvtk9.1 \
  libvtk9-dev \
  libxerces-c-dev \
  mencoder \
  petsc-dev \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv \
  python2.7 \
  valgrind \
  xsdcxx

# https://bugs.launchpad.net/ubuntu/+source/vtk7/+bug/1878103
# https://github.com/Chaste/chaste-docker/blob/4dd5a4819716c3defa0bfb5145bfa902bf07ecf4/Dockerfile#L89
update-alternatives --install /usr/bin/vtk vtk /usr/bin/vtk7 10

update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10

update-alternatives --install /usr/local/bin/python2 python2 /usr/bin/python2.7 5

pip install --upgrade pip
pip install texttest
