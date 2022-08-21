#!/bin/bash -e

# Source `module` command
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
module test cmake/3.9.1
module load cmake/3.9.1

./install_xsd.sh --version=4.0.0 --modules-dir=${modules_dir}
module test xsd/4.0.0

./install_xercesc.sh --version=3.2.3 --modules-dir=${modules_dir} --parallel=${ncpu}
module test xercesc/3.2.3

./install_sundials.sh --version=5.8.0 --modules-dir=${modules_dir} --parallel=${ncpu}
module test sundials/5.8.0

./install_boost.sh --version=1.74.0 --modules-dir=${modules_dir} --parallel=${ncpu}
module test boost/1.74.0

./install_vtk.sh --version=9.1.0 --modules-dir=${modules_dir} --parallel=${ncpu}
module test vtk/9.1.0

./install_petsc_hdf5.sh \
    --petsc-version=3.11.3 \
    --hdf5-version=1.10.5 \
    --petsc-arch=linux-gnu \
    --modules-dir=${modules_dir} \
    --parallel=${ncpu}

module test petsc_hdf5/3.11.3_1.10.5/linux-gnu
