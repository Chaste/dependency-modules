ARG BASE=focal

FROM ubuntu:${BASE} AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

COPY scripts/* /usr/local/bin/

# Setup user
ENV user="runner"
ENV home=/home/${user}
RUN useradd -m -d ${home} -s /bin/bash ${user}

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
    mkdir -p ${home}/modules/modulefiles && \
    chown ${user}:${user} ${home}/modules && \
    echo "export MODULES_DIR=${home}/modules" >> ${home}/.bashrc && \
    echo "module use \${MODULES_DIR}/modulefiles" >> ${home}/.bashrc && \
    echo "export TEXTTEST_HOME=/usr/local/bin/texttest" >> ${home}/.bashrc && \
    apt-get -y clean && \
    rm -rf /var/cache/apt && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

# Setup actions-runner
ENV runner_dir="${home}/actions-runner"
RUN get_runner.sh --install_dir="${runner_dir}" && \
    ${runner_dir}/bin/installdependencies.sh && \
    chown ${user}:${user} ${runner_dir} && \
    echo "export RUNNER_DIR=${runner_dir}" >> ${home}/.bashrc && \
    echo "export WORK_DIR=${home}/_work" >> ${home}/.bashrc && \
    apt-get -y clean && \
    rm -rf /var/cache/apt && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

USER ${user}
WORKDIR ${home}

ENTRYPOINT ["bash", "--login", "docker-entrypoint.sh"]
