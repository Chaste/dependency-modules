#!/bin/bash -eu

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) # https://stackoverflow.com/a/246128

. ${script_dir}/env.sh
. ${script_dir}/functions.sh

unset script_dir
