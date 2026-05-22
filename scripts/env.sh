#!/bin/bash -eu

OS_VERSION_ID=""
OS_VERSION_CODENAME=""

if [[ "$OSTYPE" =~ ^linux ]]; then
  OS_VERSION_ID="$(. /etc/os-release && echo ${VERSION_ID})"
  OS_VERSION_CODENAME="$(. /etc/os-release && echo ${VERSION_CODENAME})"

elif [[ "$OSTYPE" =~ ^darwin ]]; then
  OS_VERSION_ID="$(sw_vers -productVersion)"
  OS_VERSION_CODENAME="$(sw_vers -productName)$(echo ${OS_VERSION_ID} | cut -d. -f1)"
fi
