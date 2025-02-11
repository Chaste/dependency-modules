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

# Chaste dependencies
codename="$(. /etc/os-release && echo ${VERSION_CODENAME} | sed 's/\.//')"
echo "deb [signed-by=/usr/share/keyrings/chaste.asc] https://chaste.github.io/ubuntu ${codename}/" > /etc/apt/sources.list.d/chaste.list
wget -O /usr/share/keyrings/chaste.asc https://chaste.github.io/chaste.asc

apt-get update && \
apt-get install -y --no-install-recommends \
  chaste-dependencies \
  doxygen \
  git \
  lcov \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv \
  valgrind

# https://bugs.launchpad.net/ubuntu/+source/expat/+bug/2058415
if [ "${codename}" = 'jammy' ]; then
    apt-get install libexpat1=2.4.7-1 libexpat1-dev=2.4.7-1
    apt-mark hold libexpat1 libexpat1-dev
fi

update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10
