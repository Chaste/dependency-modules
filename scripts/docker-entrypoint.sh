#!/bin/bash -e

if [ -n "${RUNNER_REMOVE}" ]; then
    runner_config.sh
    exit 0
fi

if [ ! -d "${RUNNER_DIR}" ]; then
    runner_install.sh --install_dir="${RUNNER_DIR}"
fi

if [ ! -f "${RUNNER_DIR}/.runner" ]; then
    runner_config.sh
fi

if [ ! -f "${RUNNER_DIR}/.runner" ]; then
    echo "Runner has not been configured"
    exit 1
fi

exec "${RUNNER_DIR}/run.sh"
