#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

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
  libpetsc-real3.18 \
  libpetsc-real3.18-dbg \
  libpetsc-real3.18-dev \
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
  valgrind \
  xsdcxx

update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10

pip install --upgrade pip
pip install texttest
