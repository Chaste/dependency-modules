#!/bin/sh

# Package: chaste-dependencies
# Version: 2022.04.11
# Depends: cmake | scons, g++, libopenmpi-dev, petsc-dev, libhdf5-openmpi-dev,
#     xsdcxx, libboost-serialization-dev, libboost-filesystem-dev,
#     libboost-program-options-dev, libparmetis-dev, libmetis-dev,
#     libxerces-c-dev, libsundials-dev, libvtk7-dev | libvtk6-dev,
#     python3, python3-venv
# Recommends: git, valgrind, libpetsc-real3.15-dbg | libpetsc-real3.14-dbg |
#     libpetsc-real3.12-dbg, libfltk1.1, hdf5-tools, cmake-curses-gui
# Suggests: libgoogle-perftools-dev, doxygen, graphviz, subversion, git-svn,
#     gnuplot, paraview
# APT-Sources: https://chaste.github.io/ubuntu jammy/ Packages

export DEBIAN_FRONTEND=noninteractive

# https://chaste.github.io/docs/installguides/ubuntu-package/
echo "deb [signed-by=/usr/share/keyrings/chaste.asc] https://chaste.github.io/ubuntu jammy/" > /etc/apt/sources.list.d/chaste.list
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 422C4D99
wget -O /usr/share/keyrings/chaste.asc https://chaste.github.io/chaste.asc

apt-get update && \
apt-get install -y --no-install-recommends \
    chaste-dependencies \
    git \
    valgrind \
    libpetsc-real3.15-dbg \
    libfltk1.1 \
    hdf5-tools \
    cmake-curses-gui \
    lcov \
    doxygen \
    graphviz \
    gnuplot \
    paraview \
    mencoder \
    python3-dev \
    python3-pip \
    python2.7 \
    libffi-dev \
    environment-modules

# libgoogle-perftools-dev: libunwind dependency version required conflicts
# with the pre-installed version on github ubuntu-22.04 runners
# https://bugs.launchpad.net/ubuntu/+source/llvm-toolchain-14/+bug/1989124

# https://bugs.launchpad.net/ubuntu/+source/vtk7/+bug/1878103
# https://github.com/Chaste/chaste-docker/blob/4dd5a4819716c3defa0bfb5145bfa902bf07ecf4/Dockerfile#L89
update-alternatives --install /usr/bin/vtk vtk /usr/bin/vtk7 10

update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10

update-alternatives --install /usr/local/bin/python2 python2 /usr/bin/python2.7 5

pip install --upgrade pip
pip install texttest
