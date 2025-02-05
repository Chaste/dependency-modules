#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# General dependencies
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
  tcl \
  wget

# Chaste dependencies
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
  libexpat1-dev \
  libexpat1 \
  libfmt-dev \
  libfontconfig1 \
  libfreetype6 \
  libfreetype6-dev \
  libgdal-dev \
  libgdal26 \
  libgl1-mesa-dev \
  libgl1-mesa-glx \
  libgl2ps-dev \
  libgl2ps1.4 \
  libglew-dev \
  libglew2.1 \
  libglu1-mesa \
  libglu1-mesa-dev \
  libglx0 \
  libjpeg-dev \
  libjpeg8 \
  libjsoncpp-dev \
  libjsoncpp1 \
  liblz4-1 \
  liblz4-dev \
  liblzma5 \
  libmysqlclient-dev \
  libmysqlclient21 \
  libnetcdf-c++4 \
  libnetcdf-cxx-legacy-dev \
  libnetcdf-dev \
  libnetcdf15 \
  libodbc1 \
  libogg-dev \
  libogg0 \
  libopengl0 \
  libpng-dev \
  libpng16-16 \
  libpq-dev \
  libpq5 \
  libproj-dev \
  libproj15 \
  libsqlite3-0 \
  libsqlite3-dev \
  libswscale-dev \
  libswscale5 \
  libtbb-dev \
  libtbb2 \
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

# Set default `python` to Python 3
update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10

pip install --upgrade pip
