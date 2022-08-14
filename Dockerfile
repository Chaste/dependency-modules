ARG BASE=focal

FROM ubuntu:${BASE} AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

COPY scripts/* /usr/local/bin/

ENV DEFAULT_USER="runner"
ENV DEFAULT_HOME="/home/${DEFAULT_USER}"

RUN useradd -m -d ${DEFAULT_HOME} -s /bin/bash ${DEFAULT_USER}

ENV RUNNER_DIR="${DEFAULT_HOME}/actions-runner"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-utils \
        apt-transport-https \
        ca-certificates \
        gnupg \
        openssl \
        wget \
        curl \
        rsync \
        jq \
        nano \
        vim && \
    setup_ubuntu2004.sh && \
    get_runner.sh --install_dir="${RUNNER_DIR}" && \
    ${RUNNER_DIR}/bin/installdependencies.sh && \
    chown ${DEFAULT_USER}:${DEFAULT_USER} ${RUNNER_DIR} && \
    apt-get -y clean && \
    rm -rf /var/cache/apt && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

ENV TEXTTEST_HOME="/usr/local/bin/texttest"
ENV MODULES_DIR="${DEFAULT_HOME}/modules"
ENV WORK_DIR="${DEFAULT_HOME}/_work"

USER ${DEFAULT_USER}:${DEFAULT_USER}
WORKDIR ${DEFAULT_HOME}

VOLUME ["${DEFAULT_HOME}"]

ENTRYPOINT ["docker-entrypoint.sh"]
