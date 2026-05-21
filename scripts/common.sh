#!/bin/bash -eu

common_dir="$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" # https://stackoverflow.com/a/246128

. ${common_dir}/env.sh
. ${common_dir}/functions.sh

unset common_dir
