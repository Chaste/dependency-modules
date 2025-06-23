![boost](https://github.com/Chaste/dependency-modules/actions/workflows/build-boost.yml/badge.svg)
![hdf5](https://github.com/Chaste/dependency-modules/actions/workflows/build-hdf5.yml/badge.svg)
![petsc](https://github.com/Chaste/dependency-modules/actions/workflows/build-petsc.yml/badge.svg)
![sundials](https://github.com/Chaste/dependency-modules/actions/workflows/build-sundials.yml/badge.svg)
![vtk](https://github.com/Chaste/dependency-modules/actions/workflows/build-vtk.yml/badge.svg)
![xercesc](https://github.com/Chaste/dependency-modules/actions/workflows/build-xercesc.yml/badge.svg)
![xsd](https://github.com/Chaste/dependency-modules/actions/workflows/build-xsd.yml/badge.svg)

# Chaste Dependency Modules

This repository contains utility scripts for building and installing Chaste's software dependencies as environment modules. It also contains Dockerfiles for building GitHub runner Docker images with specified dependency versions.

## Usage

### 1. Install Environment Modules

The [Environment Modules](https://modules.readthedocs.io/) system allows users to switch between different software versions installed on the same system by reconfiguring the shell environment.

See the Environment Modules [documentation](https://modules.readthedocs.io/en/latest/INSTALL.html) for installation instructions on different systems. On Ubuntu, `environment-modules` can be installed from the `apt` repository:

``` bash
apt-get install environment-modules
```

> [!IMPORTANT]
> To activate the Environment Modules system after installation, close the current shell and start a new session. Alternatively, load the activation script directly into the current shell:
> ```bash
> source /etc/profile.d/modules.sh
> ```

### 2. Create a modules directory

[Modulefiles](https://modules.readthedocs.io/en/latest/modulefile.html) are recipes used to reconfigure the shell environment for alternative software versions. The `MODULEPATH` environment variable is a list of locations where modulefiles are stored on the system.

> [!TIP]
> Directories containing modulefiles can be added to `MODULEPATH` using the command `module use <path/to/modulefiles>`.

The commands below create a directory for modules and adds it to the `MODULEPATH`.

```sh
# Create a directory for storing modulefiles
MODULES_DIR=${HOME}/modules
mkdir -p ${MODULES_DIR}/modulefiles

# Add the directory to MODULEPATH
module use ${MODULES_DIR}/modulefiles

# Add the directory to MODULEPATH automatically in future bash sessions
echo "module use ${MODULES_DIR}/modulefiles" >> ${HOME}/.bashrc
```

### 3. Install Chaste dependencies

Clone this repository and navigate to the build scripts

```sh
git clone https://github.com/Chaste/dependency-modules.git
cd dependency-modules/scripts/custom
```

> [!NOTE]
> Running the build scripts will build and install software in this directory structure:
>```
><MODULES_DIR>
>|-- modulefiles/
>|-- opt/
>`-- src/
>```
> Software will be downloaded and built in `src/` and installed in `opt/`.
> A modulefile for each software built will be created in `modulefiles/`.

Install XSD
```sh
./install_xsd.sh --version=4.0.0 --modules-dir=${MODULES_DIR}
```

Install Xerces-C
```sh
./install_xercesc.sh --version=3.2.4 --modules-dir=${MODULES_DIR} --parallel=4
```

Install SUNDIALS
```sh
./install_sundials.sh --version=6.4.0 --modules-dir=${MODULES_DIR} --parallel=4
```

Install Boost
```sh
./install_boost.sh --version=1.83.0 --modules-dir=${MODULES_DIR} --parallel=4
```

Install HDF5
```sh
./install_hdf5.sh --version=1.10.10 --modules-dir=${MODULES_DIR} --parallel=4
```

Install PETSc
```sh
./install_petsc.sh --version=3.19.6 --arch=linux-gnu-opt --modules-dir=${MODULES_DIR} --parallel=4
```

Install VTK
```sh
./install_vtk.sh --version=9.3.1 --modules-dir=${MODULES_DIR} --parallel=4
```

> [!TIP]
> After installation empty the `src/` directory as the build files are no longer needed.
> ```sh
> cd ${MODULES_DIR} && rm -rI src/*
> ```

### 4. Load installed software modules

Use `module avail` to show available software modules
```
---------------- /home/<user>/modules/modulefiles ----------------
boost/1.83.0                                    vtk/9.3.1
hdf5/1.10.10                                    xercesc/3.2.4
petsc/3.19.6/linux-gnu-opt                      xsd/4.0.0
sundials/6.4.0
```

Use `module load` to activate software modules
``` bash
module load xsd/4.0.0
module load xercesc/3.2.4
module load sundials/6.4.0
module load boost/1.83.0
module load hdf5/1.10.10
module load petsc/3.19.6/linux-gnu-opt
module load vtk/9.3.1
```

### 5. Build Chaste

Configure and build Chaste as normal following the instructions in the [documentation](https://chaste.github.io/docs/installguides/).

## Module commands

Below is a subset of commonly used `module` commands. See the environment modules [documentation](https://modules.readthedocs.io/en/latest/module.html) for a more comprehensive manual.

| Command                                     |  Description                                                      |
| ------------------------------------------- | ----------------------------------------------------------------- |
| `module use <path/to/modulefiles>`          |  Make software modules located on the specified path available.   |
|                                             |                                                                   |
| `module avail`                              |  List all available software modules.                             |
|                                             |                                                                   |
| `module avail <search_string>`              |  Search for software modules that match the search string.        |
|                                             |                                                                   |
| `module load <module>`                      |  Load a software module into the environment.                     |
|                                             |                                                                   |
| `module list`                               |  List all currently loaded software modules.                      |
|                                             |                                                                   |
| `module unload <module>`                    |  Unload a software module from the environment.                   |
|                                             |                                                                   |
| `module purge`                              |  Unload all currently loaded software modules.                    |
|                                             |                                                                   |
| `module switch <module/ver0> <module/ver1>` |  Unload `module/ver0` and load `module/ver1`.                     |
|                                             |                                                                   |
| `module show <module>`                      |  Show the environment settings for a module.                      |
