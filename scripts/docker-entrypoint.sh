#!/bin/bash -e

if [ -n "${RUNNER_REMOVE}" ]; then
    runner_config.sh
    unset RUNNER_PA_TOKEN
    exit 0
fi

if [ ! -f "${RUNNER_DIR}/.runner" ]; then
    runner_config.sh
fi
unset RUNNER_PA_TOKEN

if [ ! -f "${RUNNER_DIR}/.runner" ]; then
    echo "Runner has not been configured"
    exit 1
fi

exec "${RUNNER_DIR}/run.sh"
