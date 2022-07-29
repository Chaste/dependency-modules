#!/bin/bash -e

# Start `module` command
source /etc/profile.d/modules.sh

# Prepare modules base directory
modules_dir=${HOME}/modules
mkdir -p ${modules_dir}/modulefiles

# Add modulefiles directory to user profile configuration
grep -qxF "module use ${modules_dir}/modulefiles" ${HOME}/.bashrc \
    || echo "module use ${modules_dir}/modulefiles" >> ${HOME}/.bashrc
source ${HOME}/.bashrc

# Set max number of parallel processes
ncpu=$(( $(nproc) < 8 ? $(nproc) : 8 ))

# Install specific dependency versions
./install_cmake.sh --version=3.9.1 --modules-dir=${modules_dir} --parallel=${ncpu}
module load cmake/3.9.1

./install_xsd.sh --version=4.0.0 --modules-dir=${modules_dir}

./install_xercesc.sh --version=3.2.3 --modules-dir=${modules_dir} --parallel=${ncpu}

./install_sundials.sh --version=5.8.0 --modules-dir=${modules_dir} --parallel=${ncpu}

./install_boost.sh --version=1.74.0 --modules-dir=${modules_dir} --parallel=${ncpu}

./install_vtk.sh --version=9.1.0 --modules-dir=${modules_dir} --parallel=${ncpu}

# For PETSc versions < 3.11.x configuration needs Python 2
./install_python.sh --version=2.7.18 --modules-dir=${modules_dir} --parallel=${ncpu}
module load python/2.7.18

# PETSc 3.7.7 + HDF5 1.10.0-patch1 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.7.7 \
    --hdf5-version=1.10.0-patch1 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${modules_dir} \
    --parallel=${ncpu}

./install_petsc_hdf5.sh \
    --petsc-version=3.7.7 \
    --hdf5-version=1.10.0-patch1 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${modules_dir} \
    --parallel=${ncpu}

# For PETSc versions >= 3.11.x configuration supports Python 3
module unload python

# PETSc 3.11.3 + HDF5 1.10.5 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.11.3 \
    --hdf5-version=1.10.5 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${modules_dir} \
    --parallel=${ncpu}

./install_petsc_hdf5.sh \
    --petsc-version=3.11.3 \
    --hdf5-version=1.10.5 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${modules_dir} \
    --parallel=${ncpu}
