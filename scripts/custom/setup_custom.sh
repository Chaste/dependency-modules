#!/bin/sh

# Setup required libraries for building Chaste dependencies on Ubuntu LTS
script_dir="$(
    cd "$(dirname "$0")"
    pwd
)"

codename="$(. /etc/os-release && echo ${VERSION_CODENAME} | sed 's/\.//')"

if [ "${codename}" = 'jammy' ]; then
  ${script_dir}/setup_ubuntu_2204.sh

elif [ "${codename}" = 'noble' ]; then
  ${script_dir}/setup_ubuntu_2404.sh

elif [ "${codename}" = 'resolute' ]; then
  ${script_dir}/setup_ubuntu_2604.sh

else
  echo "Unsupported Ubuntu version: ${codename}"
  exit 1
fi
