#!/bin/bash -e

# Install Environment Modules
sudo apt-get install tcl environment-modules

# Source `module` command
source /etc/profile.d/modules.sh

# Create base directories for installing modules
modules_dir=${HOME}/modules
mkdir -p ${modules_dir}/src
mkdir -p ${modules_dir}/opt
mkdir -p ${modules_dir}/modulefiles

# Add modulefiles directory to MODULEPATH
module use ${modules_dir}/modulefiles

# Add modulefiles directory to bash user profile configuration
echo "module use ${modules_dir}/modulefiles" >> ${HOME}/.bashrc

# Set number of parallel processes
ncpu=$(( $(nproc) < 8 ? $(nproc) : 8 ))

# Get install scripts
git clone https://github.com/Chaste/dependency-modules.git /tmp/dependency-modules
cd /tmp/dependency-modules/scripts

# Install specific dependency versions
./install_cmake.sh --version=3.24.1 --modules-dir=${modules_dir} --parallel=${ncpu}
module test cmake/3.24.1
module load cmake/3.24.1

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

# Cleanup
cd -
rm -rf ${modules_dir}/src/*
rm -rf /tmp/dependency-modules
