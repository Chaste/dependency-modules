ARG BASE=jammy

FROM ubuntu:${BASE}

ARG BOOST
ARG HDF5
ARG PETSC
ARG SUNDIALS
ARG VTK
ARG XERCESC
ARG XSD

SHELL ["/bin/bash", "-e", "-o", "pipefail", "-c"]

USER root

ENV DEFAULT_USER="runner" \
    DEFAULT_HOME="/home/runner" \
    RUNNER_DIR="/home/runner/actions-runner" \
    RUNNER_WORK_DIR="/home/runner/_work" \
    MODULES_DIR="/home/runner/modules"

COPY scripts/ /usr/local/bin/

RUN useradd -r -m -d ${DEFAULT_HOME} -s /bin/bash ${DEFAULT_USER} && \
    os_id="$(. /etc/os-release && echo ${VERSION_ID} | sed 's/\.//')" && \
    setup_ubuntu${os_id}.sh && \
    runner_install.sh --install_dir="/tmp/tmp-runner" && \
    /tmp/tmp-runner/bin/installdependencies.sh && \
    apt-get -y clean && \
    rm -rf /var/cache/apt && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

USER ${DEFAULT_USER}:${DEFAULT_USER}
WORKDIR ${DEFAULT_HOME}

RUN source /etc/profile.d/modules.sh && \
    mkdir -p ${MODULES_DIR}/modulefiles && \
    module use ${MODULES_DIR}/modulefiles && \
    echo "module use ${MODULES_DIR}/modulefiles" >> ${DEFAULT_HOME}/.bashrc && \
    install_xsd.sh \
        --version=${XSD} \
        --modules-dir=${MODULES_DIR} && \
    module test xsd && \
    install_xercesc.sh \
        --version=${XERCESC} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test xercesc && \
    install_sundials.sh \
        --version=${SUNDIALS} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test sundials && \
    install_boost.sh \
        --version=${BOOST} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test boost && \
    install_vtk.sh \
        --version=${VTK} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test vtk && \
    install_petsc_hdf5.sh \
        --petsc-version=${PETSC} \
        --petsc-arch=linux-gnu \
        --hdf5-version=${HDF5} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test petsc_hdf5 && \
    rm -rf ${MODULES_DIR}/src/* && \
    rm -rf /tmp/*

ENTRYPOINT ["docker-entrypoint.sh"]
