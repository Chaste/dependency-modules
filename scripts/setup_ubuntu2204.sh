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

# https://chaste.github.io/docs/installguides/ubuntu-package/

export DEBIAN_FRONTEND=noninteractive

apt-get update && \
apt-get install -y --no-install-recommends \
  cmake \
  doxygen \
  environment-modules \
  g++ \
  git \
  lcov \
  make \
  python2.7 \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv

# Install OpenGL for VTK
# https://discourse.vtk.org/t/trouble-installing-vtk-on-ubuntu/5148
apt-get install -y --no-install-recommends \
  freeglut3 \
  freeglut3-dev \
  libgl1-mesa-dev \
  libgl1-mesa-glx \
  libglew2.2 \
  libglew-dev \
  libglu1-mesa \
  libglu1-mesa-dev

# Set default `python` to Python 3
update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10

# Python 2 is needed to configure PETSc < 3.11.x
update-alternatives --install /usr/local/bin/python2 python2 /usr/bin/python2.7 5

pip install --upgrade pip
