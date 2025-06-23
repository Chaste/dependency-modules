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

# Get install scripts
git clone https://github.com/Chaste/dependency-modules.git /tmp/dependency-modules
cd /tmp/dependency-modules/scripts

# Install specific dependency versions
./install_cmake.sh --version=3.28.6 --modules-dir=${modules_dir} --parallel=4
module test cmake/3.28.6
module load cmake/3.28.6

./install_xsd.sh --version=4.0.0 --modules-dir=${modules_dir}
module test xsd/4.0.0

./install_xercesc.sh --version=3.2.4 --modules-dir=${modules_dir} --parallel=4
module test xercesc/3.2.4

./install_sundials.sh --version=6.4.0 --modules-dir=${modules_dir} --parallel=4
module test sundials/6.4.0

./install_boost.sh --version=1.83.0 --modules-dir=${modules_dir} --parallel=4
module test boost/1.83.0

./install_hdf5.sh --version=1.10.10 --modules-dir=${modules_dir} --parallel=4
module test hdf5/1.10.10

./install_petsc.sh --version=3.19.6 --arch=linux-gnu --modules-dir=${modules_dir} --parallel=4
module test petsc/3.19.6/linux-gnu

./install_vtk.sh --version=9.3.1 --modules-dir=${modules_dir} --parallel=4
module test vtk/9.3.1

# Cleanup
cd -
rm -rf ${modules_dir}/src/*
rm -rf /tmp/dependency-modules
