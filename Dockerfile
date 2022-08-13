ARG BASE=focal

FROM ubuntu:${BASE} AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Setup user
ENV user="runner"
ENV user_home=/home/${user}
RUN useradd -m -d ${user_home} -s /bin/bash ${user}
COPY scripts/ /usr/local/bin/

# Setup dependencies
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
    mkdir -p ${user_home}/modules/modulefiles && \
    echo "export MODULES_DIR=${user_home}/modules" >> .bashrc && \
    echo "module use \${MODULES_DIR}/modulefiles" >> .bashrc && \
    echo "export TEXTTEST_HOME=/usr/local/bin/texttest" >> .bashrc && \
    apt-get -y clean && \
    rm -rf /var/cache/apt && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

# Setup actions-runner
ENV runner_dir="${user_home}/actions-runner"
RUN get_runner.sh --install_dir="${runner_dir}" && \
    ${runner_dir}/bin/installdependencies.sh && \
    chown ${user}:${user} ${runner_dir} && \
    echo "export RUNNER_DIR=${runner_dir}" >> .bashrc && \
    apt-get -y clean && \
    rm -rf /var/cache/apt && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

USER ${user}
WORKDIR ${user_home}
