#!/bin/bash

# Setup required libraries for building Chaste dependencies on Ubuntu LTS
script_dir="$(cd "$(dirname "$0")"; pwd)"
. ${script_dir}/common.sh

if [ "${OS_VERSION_CODENAME}" = 'jammy' ]; then
  ${script_dir}/setup_ubuntu_2204.sh

elif [ "${OS_VERSION_CODENAME}" = 'noble' ]; then
  ${script_dir}/setup_ubuntu_2404.sh

elif [ "${OS_VERSION_CODENAME}" = 'resolute' ]; then
  ${script_dir}/setup_ubuntu_2604.sh

else
  echo "Unsupported Ubuntu version: ${OS_VERSION_CODENAME}"
  exit 1
fi
