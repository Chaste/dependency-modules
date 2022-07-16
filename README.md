![ubuntu](https://github.com/Chaste/dependency-modules/actions/workflows/ubuntu.yml/badge.svg)

# Chaste Dependency Modules
Utility scripts for installing Chaste dependencies as Environment Modules

## TL;DR
```
MODULES_DIR=${HOME}/modules

mkdir -p ${MODULES_DIR}

module use ${MODULES_DIR}

./install_xsd.sh --version=4.0.0 --modules-dir=${MODULES_DIR}

./install_xercesc.sh --version=3.2.1 --modules-dir=${MODULES_DIR}

./install_sundials.sh --version=5.8.0 --modules-dir=${MODULES_DIR}

./install_boost.sh --version=1.69.0 --modules-dir=${MODULES_DIR}

./install_vtk.sh --version=9.0.0 --modules-dir=${MODULES_DIR}

./install_petsc_hdf5.sh --petsc-version=3.12.4 --hdf5-version=1.10.4 \
    --petsc-arch=linux-gnu --modules-dir=${MODULES_DIR}

module load xsd/4.0.0
module load xercesc/3.2.1
module load sundials/5.8.0
module load boost/1.69.0
module load vtk/9.0.0
module load petsc_hdf5/3.12.4_1.10.4/linux-gnu
```
