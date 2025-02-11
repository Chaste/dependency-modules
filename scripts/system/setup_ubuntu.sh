#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

codename="$(. /etc/os-release && echo ${VERSION_CODENAME} | sed 's/\.//')"

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

update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10
