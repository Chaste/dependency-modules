#!/bin/bash -e

if [ ! -f "${RUNNER_DIR}/.runner" ]; then
    config_runner.sh "$@" \
        --runner_dir="${RUNNER_DIR}" \
        --work_dir="${WORK_DIR}"
fi
unset PA_TOKEN

. /etc/profile.d/modules.sh
mkdir -p ${MODULES_DIR}/modulefiles
module use ${MODULES_DIR}/modulefiles

exec "${RUNNER_DIR}/run.sh"
