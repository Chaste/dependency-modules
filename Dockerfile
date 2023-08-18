ARG BASE=jammy

FROM ubuntu:${BASE}

ARG XSD=4.0.0
ARG XERCESC=3.2.4
ARG SUNDIALS=5.8.0
ARG BOOST=1.74.0
ARG VTK=8.2.0
ARG PETSC=3.15.5
ARG HDF5=1.10.8

SHELL ["/bin/bash", "-e", "-o", "pipefail", "-c"]

USER root

ENV DEFAULT_USER="runner"
ENV DEFAULT_HOME="/home/${DEFAULT_USER}"

ENV RUNNER_DIR="${DEFAULT_HOME}/actions-runner"
ENV RUNNER_WORK_DIR="${DEFAULT_HOME}/_work"

ENV MODULES_DIR="${DEFAULT_HOME}/modules"

COPY scripts/ /usr/local/bin/

RUN useradd -r -m -d ${DEFAULT_HOME} -s /bin/bash ${DEFAULT_USER} && \
    . /etc/os-release && \
    os_id="$(echo ${VERSION_ID} | sed 's/\.//')" && \
    setup_ubuntu${os_id}.sh && \
    runner_install.sh --install_dir="/tmp/tmp-runner" && \
    /tmp/tmp-runner/bin/installdependencies.sh && \
    mkdir -p ${MODULES_DIR}/src && \
    mkdir -p ${MODULES_DIR}/opt && \
    mkdir -p ${MODULES_DIR}/modulefiles && \
    echo "module use ${MODULES_DIR}/modulefiles" >> ${DEFAULT_HOME}/.bashrc && \
    chown -R ${DEFAULT_USER}:${DEFAULT_USER} ${MODULES_DIR} && \
    apt-get -y clean && \
    rm -rf /var/cache/apt && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

USER ${DEFAULT_USER}:${DEFAULT_USER}
WORKDIR ${DEFAULT_HOME}

RUN source /etc/profile.d/modules.sh && \
    module use ${MODULES_DIR}/modulefiles && \
    install_xsd.sh \
        --version=${XSD} \
        --modules-dir=${MODULES_DIR} && \
    module test xsd/${XSD} && \
    install_xercesc.sh \
        --version=${XERCESC} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test xercesc/${XERCESC} && \
    install_sundials.sh \
        --version=${SUNDIALS} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test sundials/${SUNDIALS} && \
    install_boost.sh \
        --version=${BOOST} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test boost/${BOOST} && \
    install_vtk.sh \
        --version=${VTK} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test vtk/${VTK} && \
    install_petsc_hdf5.sh \
        --petsc-version=${PETSC} \
        --petsc-arch=linux-gnu \
        --hdf5-version=${HDF5} \
        --parallel=$(nproc) \
        --modules-dir=${MODULES_DIR} && \
    module test petsc_hdf5/${PETSC}_${HDF5}/linux-gnu && \
    rm -rf ${MODULES_DIR}/src/* && \
    rm -rf /tmp/*

ENTRYPOINT ["docker-entrypoint.sh"]
