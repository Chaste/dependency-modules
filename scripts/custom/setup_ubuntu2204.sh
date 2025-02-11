#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# System dependencies
apt-get update && \
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

# Build dependencies
apt-get install -y --no-install-recommends \
  build-essential \
  cmake \
  doxygen \
  git \
  lcov \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv \
  valgrind

# Chaste dependencies
apt-get install -y --no-install-recommends \
  libfftw3-3 \
  libfftw3-bin \
  libfftw3-dev

# VTK dependencies
apt-get install -y --no-install-recommends \
  freeglut3 \
  freeglut3-dev \
  libavcodec-dev \
  libavcodec58 \
  libavformat-dev \
  libavformat58 \
  libavutil-dev \
  libavutil56 \
  libdouble-conversion-dev \
  libdouble-conversion3 \
  libeigen3-dev \
  libfmt-dev \
  libfmt8 \
  libfontconfig1 \
  libfreetype6 \
  libfreetype6-dev \
  libgl1-mesa-dev \
  libgl1-mesa-glx \
  libgl2ps-dev \
  libgl2ps1.4 \
  libglew-dev \
  libglew2.2 \
  libglu1-mesa \
  libglu1-mesa-dev \
  libglx0 \
  libjpeg-dev \
  libjpeg8 \
  libjsoncpp-dev \
  libjsoncpp25 \
  liblz4-1 \
  liblz4-dev \
  liblzma5 \
  libmysqlclient-dev \
  libmysqlclient21 \
  libnetcdf-c++4 \
  libnetcdf-cxx-legacy-dev \
  libnetcdf-dev \
  libnetcdf19 \
  libodbc2 \
  libogg-dev \
  libogg0 \
  libopengl0 \
  libpng-dev \
  libpng16-16 \
  libpq-dev \
  libpq5 \
  libproj-dev \
  libproj22 \
  libsqlite3-0 \
  libsqlite3-dev \
  libswscale-dev \
  libswscale5 \
  libtbb-dev \
  libtbb12 \
  libtcl8.6 \
  libtheora-dev \
  libtheora0 \
  libtiff-dev \
  libtiff5 \
  libtk8.6 \
  libutfcpp-dev \
  libx11-6 \
  libx11-dev \
  libxcursor-dev \
  libxcursor1 \
  libxft-dev \
  libxml2 \
  libxml2-dev \
  libxss-dev \
  libxt-dev \
  libxt6 \
  sqlite3 \
  tcl-dev \
  tk-dev \
  x11proto-core-dev \
  zlib1g \
  zlib1g-dev

# mpi-default-bin mpi-default-dev:
# To be supplied by custom PETSc build for better compatibility.

# libexpat1-dev libexpat1:
# To be supplied by custom VTK build due to version conflicts.

# libgdal-dev libgdal30:
# To be supplied by custom VTK build due to reliance on system boost.

update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10
