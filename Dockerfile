ARG BASE=focal

# Build Stage 1: install dependencies
FROM ubuntu:${BASE} AS base

USER root

ENV user="runner"
ENV user_home=/home/${user}
RUN useradd -m -d ${user_home} -s /bin/bash ${user}

COPY --chown=${user}:${user} scripts ${user_home}/scripts

WORKDIR ${user_home}

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
    rm -rf /var/lib/apt/lists/*

RUN ./scripts/setup_ubuntu2004 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p modules/modulefiles && \
    echo "export MODULES_DIR=${user_home}/modules" >> .bashrc && \
    echo "module use \${MODULES_DIR}/modulefiles" >> .bashrc && \
    echo "export TEXTTEST_HOME=/usr/local/bin/texttest" >> .bashrc

# Build Stage 2: install actions-runner
FROM base
USER ${user}
WORKDIR ${user_home}

RUN ./scripts/setup_runner.sh \
        --scope=${scope} \
        --owner=${owner} \
        --repo=${repo} \
        --token=${token} \
        --runner_name=${runner_name} \
        --runner_labels=${runner_labels} \
        --runner_group=${runner_group} \
        --runner_dir="${user_home}/actions-runner" \
        --work_dir="${user_home}/_work"

RUN echo "export PATH=\$PATH:${user_home}/actions-runner" >> .bashrc
