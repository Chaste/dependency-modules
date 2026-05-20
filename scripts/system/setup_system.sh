#!/bin/bash

# Setup Chaste system dependency versions on Ubuntu
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) # https://stackoverflow.com/a/246128
. ${script_dir}/../common.sh

export DEBIAN_FRONTEND=noninteractive

# Base dependencies
apt-get update &&
  apt-get install -y --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    environment-modules \
    gnupg \
    jq \
    openssl \
    rsync \
    wget

# Build/dev dependencies
apt-get install -y --no-install-recommends \
  build-essential \
  cmake \
  cmake-curses-gui \
  doxygen \
  git \
  lcov \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv \
  valgrind

# Chaste dependencies

if [ "${OS_VERSION_CODENAME}" = 'plucky' ]; then
  # Install manually: Ubuntu 25.04 Plucky Puffin repository not yet available
  apt-get install -y --no-install-recommends \
    hdf5-tools \
    libboost-serialization-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libhdf5-openmpi-dev \
    libmetis-dev \
    libopenmpi-dev \
    libpetsc-real3.22 \
    libpetsc-real3.22-dbg \
    libpetsc-real3.22-dev \
    libscotchparmetis-dev \
    libsundials-dev \
    libvtk9.3 \
    libvtk9-dev \
    libxerces-c-dev \
    petsc-dev \
    xsdcxx
elif [ "${OS_VERSION_CODENAME}" = 'questing' ]; then
  # Install manually: Ubuntu 25.10 Questing Quokka repository not yet available
  apt-get install -y --no-install-recommends \
    hdf5-tools \
    libboost-serialization-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libhdf5-openmpi-dev \
    libmetis-dev \
    libopenmpi-dev \
    libpetsc-real3.22 \
    libpetsc-real3.22-dbg \
    libpetsc-real3.22-dev \
    libscotchparmetis-dev \
    libsundials-dev \
    libvtk9.3 \
    libvtk9-dev \
    libxerces-c-dev \
    petsc-dev \
    xsdcxx
else
  # Install from repository
  wget -O /usr/share/keyrings/chaste.asc https://chaste.github.io/chaste.asc
  repo="deb [signed-by=/usr/share/keyrings/chaste.asc] https://chaste.github.io/ubuntu ${OS_VERSION_CODENAME}/"
  echo "${repo}" >/etc/apt/sources.list.d/chaste.list
  apt-get update && apt-get install -y --no-install-recommends chaste-dependencies
fi

# Workaround for libexpat1 issue on Ubuntu Jammy
# https://bugs.launchpad.net/ubuntu/+source/expat/+bug/2058415
if [ "${OS_VERSION_CODENAME}" = 'jammy' ]; then
  apt-get install -y --allow-downgrades libexpat1=2.4.7-1 libexpat1-dev=2.4.7-1
  apt-mark hold libexpat1 libexpat1-dev
fi

update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10
