#!/bin/bash
# set -o errexit
# set -o nounset

MODULES_DIR=~/modules
grep -qxF "module use ${MODULES_DIR}/modulefiles" ~/.bashrc \
    || echo "module use ${MODULES_DIR}/modulefiles" >> ~/.bashrc
source ~/.bashrc

NPROC=$(( $(nproc) < 8 ? $(nproc) : 8 ))

./install_python.sh --version=2.7.18 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_python.sh --version=3.8.12 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

module load python/3.8.12

./install_cmake.sh --version=3.9.1 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

module load cmake/3.9.1

./install_xsd.sh --version=3.3.0 --modules-dir=${MODULES_DIR}
./install_xsd.sh --version=4.0.0 --modules-dir=${MODULES_DIR}

./install_xercesc.sh --version=3.2.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_xercesc.sh --version=3.2.1 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

./install_sundials.sh --version=2.7.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_sundials.sh --version=3.1.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_sundials.sh --version=4.1.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_sundials.sh --version=5.0.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

./install_boost.sh --version=1.62.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_boost.sh --version=1.66.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_boost.sh --version=1.67.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_boost.sh --version=1.69.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

./install_vtk.sh --version=6.3.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_vtk.sh --version=7.0.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_vtk.sh --version=7.1.1 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_vtk.sh --version=8.0.1 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_vtk.sh --version=8.1.1 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_vtk.sh --version=8.2.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_vtk.sh --version=9.0.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

./install_vtk.sh --version=7.0.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

module switch python/2.7.18  # For PETSc versions < 3.11.x configuration needs Python 2

# PETSc 3.6.4 + HDF5 1.8.16 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.6.4 \
    --hdf5-version=1.8.16 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.6.4 \
    --hdf5-version=1.8.16 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

# PETSc 3.7.7 + HDF5 1.10.0-patch1 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.7.7 \
    --hdf5-version=1.10.0-patch1 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.7.7 \
    --hdf5-version=1.10.0-patch1 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

# PETSc 3.8.4 + HDF5 1.8.21 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.8.4 \
    --hdf5-version=1.8.21 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.8.4 \
    --hdf5-version=1.8.21 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

# PETSc 3.9.4 + HDF5 1.10.3 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.9.4 \
    --hdf5-version=1.10.3 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.9.4 \
    --hdf5-version=1.10.3 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

# PETSc 3.10.5 + HDF5 1.10.4 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.10.5 \
    --hdf5-version=1.10.4 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.10.5 \
    --hdf5-version=1.10.4 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

module switch python/3.8.12  # For PETSc versions >= 3.11.x configuration supports Python 3

# PETSc 3.11.3 + HDF5 1.10.5 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.11.3 \
    --hdf5-version=1.10.5 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.11.3 \
    --hdf5-version=1.10.5 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

# PETSc 3.12.4 + HDF5 1.10.4 + MPICH 3.4a3
./install_petsc_hdf5.sh \
    --petsc-version=3.12.4 \
    --hdf5-version=1.10.4 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.4a3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.12.4 \
    --hdf5-version=1.10.4 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.4a3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}
