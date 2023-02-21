ARG BASE=focal

FROM ubuntu:${BASE}

SHELL ["/bin/bash", "-e", "-o", "pipefail", "-c"]

USER root

ENV DEFAULT_USER="runner"
ENV DEFAULT_HOME="/home/${DEFAULT_USER}"

ENV RUNNER_DIR="${DEFAULT_HOME}/actions-runner"
ENV RUNNER_WORK_DIR="${DEFAULT_HOME}/_work"

ENV MODULES_DIR="${DEFAULT_HOME}/modules"

COPY scripts/ /usr/local/bin/

RUN useradd -r -m -d ${DEFAULT_HOME} -s /bin/bash ${DEFAULT_USER} && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
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
    . /etc/os-release && \
    os_num="$(echo ${VERSION_ID} | sed 's/\.//')" && \
    setup_ubuntu${os_num}.sh && \
    runner_install.sh --install_dir="/tmp/tmp-runner" && \
    /tmp/tmp-runner/bin/installdependencies.sh && \
    mkdir -p ${MODULES_DIR}/src && \
    mkdir -p ${MODULES_DIR}/opt && \
    mkdir -p ${MODULES_DIR}/modulefiles && \
    install_xsd.sh \
        --version=4.0.0 \
        --modules-dir=${MODULES_DIR} && \
    install_xercesc.sh \
        --version=3.2.3 \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    install_sundials.sh \
        --version=5.8.0 \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    install_boost.sh \
        --version=1.73.0 \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    install_vtk.sh \
        --version=8.2.0 \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    install_petsc_hdf5.sh \
        --petsc-version=3.8.4 \
        --petsc-arch=linux-gnu \
        --hdf5-version=1.10.8 \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    echo "module use ${MODULES_DIR}/modulefiles" >> ${DEFAULT_HOME}/.bashrc && \
    chown -R ${DEFAULT_USER}:${DEFAULT_USER} ${MODULES_DIR} && \
    apt-get -y clean && \
    rm -rf /var/cache/apt && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/* && \
    rm -rf ${MODULES_DIR}/src/*

ENV TEXTTEST_HOME="/usr/local/bin/texttest"

USER ${DEFAULT_USER}:${DEFAULT_USER}
WORKDIR ${DEFAULT_HOME}

ENTRYPOINT ["docker-entrypoint.sh"]
