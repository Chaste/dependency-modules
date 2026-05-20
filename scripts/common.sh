#!/bin/bash -eu

common_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) # https://stackoverflow.com/a/246128

. ${common_dir}/env.sh
. ${common_dir}/functions.sh

unset common_dir
