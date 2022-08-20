#!/bin/sh

# Package: chaste-dependencies
# Version: 2018.04.18
# Depends: cmake | scons, g++, libopenmpi-dev, petsc-dev, libhdf5-openmpi-dev,
#     xsdcxx, libboost-serialization-dev, libboost-filesystem-dev,
#     libboost-program-options-dev, libparmetis-dev, libmetis-dev,
#     libxerces-c-dev, libsundials-dev | libsundials-serial-dev,
#     libvtk7-dev | libvtk6-dev | libvtk5-dev, python-lxml, python-amara,
#     python-rdflib, libproj-dev
# Recommends: git, valgrind, libpetsc3.7.7-dbg | libpetsc3.7.6-dbg |
#     libpetsc3.6.4-dbg | libpetsc3.6.2-dbg | libpetsc3.4.2-dbg,
#     libfltk1.1, hdf5-tools, cmake-curses-gui
# Suggests: libgoogle-perftools-dev, doxygen, graphviz, eclipse-cdt,
#     eclipse-egit, libsvn-java, subversion, git-svn, gnuplot, paraview
# APT-Sources: http://www.cs.ox.ac.uk/chaste/ubuntu bionic/ Packages

export DEBIAN_FRONTEND=noninteractive

echo "deb http://www.cs.ox.ac.uk/chaste/ubuntu bionic/" > /etc/apt/sources.list.d/chaste.list
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 422C4D99

apt-get update && \
apt-get install -y --no-install-recommends \
    chaste-dependencies \
    git \
    valgrind \
    libpetsc3.7.7-dbg \
    libfltk1.1 \
    hdf5-tools \
    cmake-curses-gui \
    libgoogle-perftools-dev \
    doxygen \
    graphviz \
    gnuplot \
    paraview \
    mencoder \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    python2.7 \
    libffi-dev \
    tcl \
    environment-modules

# https://bugs.launchpad.net/ubuntu/+source/vtk7/+bug/1878103
# https://github.com/Chaste/chaste-docker/blob/4dd5a4819716c3defa0bfb5145bfa902bf07ecf4/Dockerfile#L89
update-alternatives --install /usr/bin/vtk vtk /usr/bin/vtk7 10

update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10

update-alternatives --install /usr/local/bin/python2 python2 /usr/bin/python2.7 5

pip install --upgrade pip
pip install texttest
