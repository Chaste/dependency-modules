![boost](https://github.com/Chaste/dependency-modules/actions/workflows/build-boost.yml/badge.svg)
![petsc_hdf5](https://github.com/Chaste/dependency-modules/actions/workflows/build-petsc_hdf5.yml/badge.svg)
![sundials](https://github.com/Chaste/dependency-modules/actions/workflows/build-sundials.yml/badge.svg)
![vtk](https://github.com/Chaste/dependency-modules/actions/workflows/build-vtk.yml/badge.svg)
![xercesc](https://github.com/Chaste/dependency-modules/actions/workflows/build-xercesc.yml/badge.svg)
![xsd](https://github.com/Chaste/dependency-modules/actions/workflows/build-xsd.yml/badge.svg)

# Chaste Dependency Modules

Utility scripts for building and installing Chaste's software dependencies as environment modules.

## Usage

### 1. Install Environment Modules

[Environment Modules](https://modules.readthedocs.io/) enables switching between software versions by reconfiguring the shell environment.

Installation on Ubuntu:

``` bash
apt-get install environment-modules
```

To activate environment modules, exit the current shell and open a new one. Alternatively it can be loaded into the current shell:
```bash
source /etc/profile.d/modules.sh
```

See [Installing modules on Unix](https://modules.readthedocs.io/en/latest/INSTALL.html) for more details.

### 2. Prepare modulefiles location

[Modulefiles](https://modules.readthedocs.io/en/latest/modulefile.html) are recipes for configuring the shell environment for alternative software builds. The `MODULEPATH` environment variable is a list of locations where modulefiles are stored. New locations can be added to `MODULEPATH` using the command `module use <path/to/modulefiles>`.

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

Running the build scripts will build and install software in this directory structure:

```
<MODULES_DIR>
|-- modulefiles/
|-- opt/
`-- src/
```

Software will be downloaded and built in `src/` and installed in `opt/`.
A modulefile for each software built will be created in `modulefiles/`.


Run the build scripts to install the software:

```sh
./install_xsd.sh --version=4.0.0 --modules-dir=${MODULES_DIR}
```

```sh
./install_xercesc.sh --version=3.2.4 --modules-dir=${MODULES_DIR}
```

```sh
./install_sundials.sh --version=6.4.0 --modules-dir=${MODULES_DIR}
```

```sh
./install_boost.sh --version=1.83.0 --modules-dir=${MODULES_DIR}
```

```sh
./install_vtk.sh --version=9.3.1 --modules-dir=${MODULES_DIR}
```

```sh
./install_petsc_hdf5.sh --petsc-version=3.19.6 --hdf5-version=1.10.10 \
    --petsc-arch=linux-gnu-opt --modules-dir=${MODULES_DIR}
```

Cleanup the `src/` directory as the build files are no longer needed

```sh
cd ${MODULES_DIR} && rm -rI src/*
```

### 4. Load the installed software

``` bash
module purge
module load xsd/4.0.0
module load xercesc/3.2.4
module load sundials/6.4.0
module load boost/1.83.0
module load vtk/9.3.1
module load petsc_hdf5/3.19.6_1.10.10/linux-gnu-opt
```

### 5. Build Chaste

Configure and build Chaste as normal following the instructions in the [documentation](https://chaste.github.io/docs/installguides/).

## Environment Module Commands

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

See the [environment modules documentation](https://modules.readthedocs.io/en/latest/module.html) for more commands and options.
