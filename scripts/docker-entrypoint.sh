#!/bin/bash -e

if [ -n "${RUNNER_OFF}" ]; then
    /bin/bash --login  # login to source /etc/profile.d/modules.sh
    exit 0
fi

if [ -n "${RUNNER_REMOVE}" ]; then
    echo "Removing runner ..."
    runner_config.sh
    exit 0
fi

if [ ! -f "${RUNNER_DIR}/config.sh" ]; then
    echo "Installing runner ..."
    runner_install.sh --install_dir="${RUNNER_DIR}"
    while read -t 1; do :; done  # skip inputs while installing
fi

if [ ! -f "${RUNNER_DIR}/.runner" ]; then
    echo "Configuring runner ..."
    runner_config.sh
fi

if [ ! -f "${RUNNER_DIR}/.runner" ]; then
    echo "Runner has not been configured"
    exit 1
fi

exec "${RUNNER_DIR}/run.sh"
