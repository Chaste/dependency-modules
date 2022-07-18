#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update && \
apt-get install -y --no-install-recommends \
apt-utils \
apt-transport-https \
ca-certificates \
gnupg \
openssl \
wget \
curl \
rsync

echo "deb [signed-by=/usr/share/keyrings/chaste.asc] http://www.cs.ox.ac.uk/chaste/ubuntu jammy/" > /etc/apt/sources.list.d/chaste.list
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 422C4D99
wget -O /usr/share/keyrings/chaste.asc https://www.cs.ox.ac.uk/chaste/ubuntu/Chaste%20Team.asc

apt-get update && \
apt-get install -y --no-install-recommends \
chaste-dependencies
