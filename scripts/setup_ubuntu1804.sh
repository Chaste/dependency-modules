#!/bin/sh

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

update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10

update-alternatives --install /usr/local/bin/python2 python2 /usr/bin/python2.7 5

pip install --upgrade pip
pip install texttest
