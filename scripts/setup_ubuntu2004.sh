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
  libavcodec57 \
  libavformat-dev \
  libavformat57 \
  libavutil-dev \
  libavutil55 \
  libdouble-conversion-dev \
  libdouble-conversion1 \
  libeigen3-dev \
  libexpat1-dev \
  libexpat1 \
  libfmt-dev \
  libfontconfig1 \
  libfreetype6 \
  libfreetype6-dev \
  libgdal-dev \
  libgdal20 \
  libgl1-mesa-dev \
  libgl1-mesa-glx \
  libgl2ps-dev \
  libgl2ps1.4 \
  libglew-dev \
  libglew2.0 \
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
  libmysqlclient20 \
  libnetcdf-c++4 \
  libnetcdf-cxx-legacy-dev \
  libnetcdf-dev \
  libnetcdf13 \
  libodbc1 \
  libogg-dev \
  libogg0 \
  libopengl0 \
  libpng-dev \
  libpng16-16 \
  libpq-dev \
  libpq5 \
  libproj-dev \
  libproj12 \
  libsqlite3-0 \
  libsqlite3-dev \
  libswscale-dev \
  libswscale4 \
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
