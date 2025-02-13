#!/bin/bash -eu

# Split version into major, minor and patch; sets minor and patch to 0 if absent.
# Usage: split_version <version>
# 1.2.3 -> 1.2.3 1 2 3
# 1.2 -> 1.2.0 1 2 0
# 1 -> 1.0.0 1 0 0
split_version()
{
    local version arr major minor patch
    version=$1
    arr=(${version//\./ })
    major=${arr[0]}
    if [ ${#arr[@]} -ge 2 ]; then
      minor=${arr[1]}
    else
      minor=0
    fi
    if [ ${#arr[@]} -ge 3 ]; then
      patch=${arr[2]}
    else
      patch=0
    fi
    echo "${major}.${minor}.${patch}" "${major}" "${minor}" "${patch}"
}
