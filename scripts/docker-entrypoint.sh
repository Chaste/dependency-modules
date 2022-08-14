#!/bin/bash -eu

if [ ! -f "${RUNNER_DIR}/.runner" ]; then
    config_runner.sh "$@" \
        --runner_dir="${RUNNER_DIR}" \
        --work_dir="${WORK_DIR}"
fi

exec "${RUNNER_DIR}/run.sh"
