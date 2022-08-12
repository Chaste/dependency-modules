ARG BASE=focal

FROM ubuntu:${BASE} AS base

ENV RUNNER_USER="runner"
ENV RUNNER_HOME=/home/${RUNNER_USER}
RUN useradd -m -d ${RUNNER_HOME} -s /bin/bash ${RUNNER_USER}

COPY --chown=${RUNNER_USER}:${RUNNER_USER} scripts ${RUNNER_HOME}/scripts

WORKDIR ${RUNNER_HOME}

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
        sudo \
        nano \
        vim && \
    rm -rf /var/lib/apt/lists/*

RUN ./scripts/setup_ubuntu2004 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p modules/modulefiles && \
    echo "export MODULES_DIR=${RUNNER_HOME}/modules" >> .bashrc && \
    echo "module use \${MODULES_DIR}/modulefiles" >> .bashrc && \
    echo "export TEXTTEST_HOME=/usr/local/bin/texttest" >> .bashrc

RUN curl -o latest.json -L https://api.github.com/repos/actions/runner/releases/latest && \
    version="$(grep -m 1 'tag_name' latest.json | cut -d\" -f4 | cut -c2-)" && \
    curl -o actions-runner.tar.gz -L "https://github.com/actions/runner/releases/download/v${version}/actions-runner-linux-x64-${version}.tar.gz" && \
    mkdir actions-runner && \
    tar -xzf actions-runner.tar.gz -C actions-runner && \
    rm -f actions-runner.tar.gz && \
    rm -f latest.json
