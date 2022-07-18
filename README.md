![tests](https://github.com/Chaste/dependency-modules/actions/workflows/ubuntu.yml/badge.svg)

# Chaste Dependency Modules
Utility scripts for installing Chaste dependencies as [Environment Modules](https://modules.readthedocs.io/).

## Usage
1. Install Environment Modules

>The [Environment Modules](https://modules.readthedocs.io/) package enables switching between different versions of an application by reconfiguring the shell environment. Installation instructions for the Environment Modules package can be found [here](https://modules.readthedocs.io/en/latest/INSTALL.html).
>
>On Ubuntu, the Environment Modules package can be installed with apt:

```bash
apt-get install environment-modules

source /etc/profile.d/modules.sh
```

2. Prepare install location

>[Modulefiles](https://modules.readthedocs.io/en/latest/modulefile.html) are used to prescribe changes to be made to the shell environment when a specific version of an application is loaded.
>
>Environment Modules searches for modulefiles on paths listed in the `MODULEPATH` environment variable. `module use directory` prepends `directory` to `MODULEPATH`.

```bash
MODULES_DIR=${HOME}/modules

mkdir -p ${MODULES_DIR}/modulefiles

module use ${MODULES_DIR}/modulefiles

echo "module use ${MODULES_DIR}/modulefiles" >> ${HOME}/.bashrc
```

>The dependency-modules utility scripts use the directory structure below. 
>
>`modulefiles` is where modulefiles will be placed.
>
>`opt` is the installation location. 
>
>`src` is a temporary location for building application versions.

```
<modules-dir>
|-- modulefiles
|-- opt
`-- src
```

3. Install Chaste dependencies as modules

>The utility scripts under `dependency-modules/scripts` require version numbers and a path to the install location:

```
./install_xsd.sh --version=4.0.0 --modules-dir=${MODULES_DIR}

./install_xercesc.sh --version=3.2.1 --modules-dir=${MODULES_DIR}

./install_sundials.sh --version=5.8.0 --modules-dir=${MODULES_DIR}

./install_boost.sh --version=1.69.0 --modules-dir=${MODULES_DIR}

./install_vtk.sh --version=9.0.0 --modules-dir=${MODULES_DIR}

./install_petsc_hdf5.sh --petsc-version=3.12.4 --hdf5-version=1.10.4 \
    --petsc-arch=linux-gnu --modules-dir=${MODULES_DIR}
```

4. Load Chaste dependency modules

>Installed software versions can be loaded into the environment with `module load modulefile`.
```
module load xsd/4.0.0

module load xercesc/3.2.1

module load sundials/5.8.0

module load boost/1.69.0

module load vtk/9.0.0

module load petsc_hdf5/3.12.4_1.10.4/linux-gnu
```

> Some useful commands:

`module unload modulefile` unloads modulefile from the environment.

`module switch [modulefile1] modulefile2` switches version from modulefile1 to modulefile2.

`module list` lists all currently loaded modulefiles.

`module purge` unloads all currently loaded modulefiles.

`module avail` lists all installed modulefiles.

`module search string` searches for modulefiles that contain `string`.

`module show modulefile` prints the environment changes prescribed by modulefile.

>Further help on the `module` command can be found [here](https://modules.readthedocs.io/en/latest/module.html).


