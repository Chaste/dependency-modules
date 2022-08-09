#!/bin/sh

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

apt-get update && apt-get install -y --install-recommends chaste-dependencies

apt-get install -y --no-install-recommends \
python3-dev \
python3-pip \
libffi-dev \
mencoder \
environment-modules

update-alternatives --install /usr/local/bin/python python /usr/bin/python3 10
update-alternatives --install /usr/local/bin/pip pip /usr/bin/pip3 10

pip install --upgrade pip
pip install texttest

export TEXTTEST_HOME=/usr/local/bin/texttest
echo "export TEXTTEST_HOME=/usr/local/bin/texttest" >> ${HOME}/.bashrc
