![ubuntu-tests](https://github.com/Chaste/dependency-modules/actions/workflows/ubuntu-tests.yml/badge.svg)

# Chaste Dependency Modules

Utility scripts for installing Chaste dependencies as Environment Modules.

## Usage

### 1. Install Environment Modules

[Environment Modules](https://modules.readthedocs.io/) enables switching between software versions by reconfiguring the shell environment.

Installation on Ubuntu:

``` bash
apt-get install environment-modules
source /etc/profile.d/modules.sh
```

See [Installing Modules on Unix](https://modules.readthedocs.io/en/latest/INSTALL.html) for more details.

### 2. Prepare modulefiles location

[Modulefiles](https://modules.readthedocs.io/en/latest/modulefile.html) are recipes for configuring the shell environment to access specific software versions. Environment Modules uses modulefiles from locations on `MODULEPATH`.

``` bash
MODULES_DIR=${HOME}/modules
mkdir -p ${MODULES_DIR}/modulefiles
module use ${MODULES_DIR}/modulefiles
echo "module use ${MODULES_DIR}/modulefiles" >> ${HOME}/.bashrc
```

The command `module use directory` prepends `directory` to `MODULEPATH`.

### 3. Install Chaste dependencies

``` bash
./install_xsd.sh --version=4.0.0 --modules-dir=${MODULES_DIR}
./install_xercesc.sh --version=3.2.1 --modules-dir=${MODULES_DIR}
./install_sundials.sh --version=5.8.0 --modules-dir=${MODULES_DIR}
./install_boost.sh --version=1.69.0 --modules-dir=${MODULES_DIR}
./install_vtk.sh --version=9.0.0 --modules-dir=${MODULES_DIR}
./install_petsc_hdf5.sh --petsc-version=3.12.4 --hdf5-version=1.10.4 \
    --petsc-arch=linux-gnu --modules-dir=${MODULES_DIR}
```

The utility scripts follow this directory structure:

``` bash
<modules-dir>
|-- modulefiles
|-- opt
`-- src
```

Builds are done from `src`.

Software versions are installed to `opt`.

Modulefiles are placed under `modulefiles`.

### 4. Load installed dependencies

``` bash
module load xsd/4.0.0
module load xercesc/3.2.1
module load sundials/5.8.0
module load boost/1.69.0
module load vtk/9.0.0
module load petsc_hdf5/3.12.4_1.10.4/linux-gnu
```

### 5. Build Chaste

See the [Chaste Guides](https://chaste.github.io/docs/installguides/ubuntu-package/) for detailed instructions on building Chaste.

## Useful commands

`module use directory` enables using modulefiles located in `directory`.

`module load modulefile` loads modulefile into the environment.

`module unload modulefile` unloads modulefile from the environment.

`module switch [modulefile1] modulefile2` switches version to modulefile2.

`module list` lists all currently loaded modulefiles.

`module purge` unloads all currently loaded modulefiles.

`module avail` lists all installed modulefiles.

`module avail string` searches for modulefiles that contain `string`.

`module show modulefile` prints the environment changes prescribed by modulefile.

See the [module command help](https://modules.readthedocs.io/en/latest/module.html) for more details.
