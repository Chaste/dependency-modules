# Build the image:
# docker build -t chaste/runner:portability-test .

# Run the container in interactive mode:
# docker run --init -it -e RUNNER_OFF=1 chaste/runner:portability-test /bin/bash

# Run the container:
# docker run --init -it chaste/runner:portability-test

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

# Setup base dependencies and install actions runner

ENV DEFAULT_USER="runner" \
    DEFAULT_HOME="/home/runner" \
    RUNNER_DIR="/home/runner/actions-runner" \
    RUNNER_WORK_DIR="/home/runner/_work" \
    MODULES_DIR="/home/runner/modules"

COPY scripts/custom/ /usr/local/bin/

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

# Build Chaste dependencies from source

RUN source /etc/profile.d/modules.sh && \
    mkdir -p ${MODULES_DIR}/modulefiles && \
    module use ${MODULES_DIR}/modulefiles && \
    echo "module use ${MODULES_DIR}/modulefiles" >> ${DEFAULT_HOME}/.bashrc && \
    install_boost.sh \
        --version=${BOOST} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test boost && \
    module load boost && \
    install_xsd.sh \
        --version=${XSD} \
        --modules-dir=${MODULES_DIR} && \
    module test xsd && \
    module load xsd && \
    install_xercesc.sh \
        --version=${XERCESC} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test xercesc && \
    module load xercesc && \
    install_petsc_hdf5.sh \
        --petsc-version=${PETSC} \
        --petsc-arch=linux-gnu \
        --hdf5-version=${HDF5} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test petsc_hdf5 && \
    module load petsc_hdf5 && \
    install_sundials.sh \
        --version=${SUNDIALS} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test sundials && \
    module load sundials && \
    install_vtk.sh \
        --version=${VTK} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test vtk && \
    module load vtk && \
    rm -rf ${MODULES_DIR}/src/* && \
    rm -rf /tmp/*

ENTRYPOINT ["docker-entrypoint.sh"]
