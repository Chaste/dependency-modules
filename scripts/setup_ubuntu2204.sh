#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

echo "deb [signed-by=/usr/share/keyrings/chaste.asc] http://www.cs.ox.ac.uk/chaste/ubuntu jammy/" > /etc/apt/sources.list.d/chaste.list
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 422C4D99
wget -O /usr/share/keyrings/chaste.asc https://www.cs.ox.ac.uk/chaste/ubuntu/Chaste%20Team.asc

apt-get update && \
apt-get install -y --no-install-recommends \
    chaste-dependencies \
    git \
    valgrind \
    libpetsc-real3.15-dbg \
    libfltk1.1 \
    hdf5-tools \
    cmake-curses-gui \
    libgoogle-perftools-dev \
    doxygen \
    graphviz \
    gnuplot \
    paraview \
    mencoder \
    python3-dev \
    python3-pip \
    libffi-dev \
    environment-modules

update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10

pip install --upgrade pip
pip install texttest

