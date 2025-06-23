#!/bin/bash -eu

# Installs PETSc from source and adds a modulefile for it.
# Arguments:
#   --version=version: The PETSc version to install (e.g., 3.15.0).
#   --arch=[{linux-gnu|linux-gnu-opt}]: The build type (default: linux-gnu).
#   --modules-dir=path: The base directory for the installation and modulefile.
#   --parallel=value: The number of parallel jobs to use for building (default: number of CPU cores).
# Example usage:
#   ./install_petsc.sh --version=3.15.0 --arch=linux-gnu --modules-dir=/path/to/modules --parallel=4
#   module load petsc/3.15.0/linux-gnu

usage()
{
    echo 'Usage: '"$(basename $0)"' --version=version --arch=[{linux-gnu|linux-gnu-opt}]'
    echo '        --modules-dir=path [--parallel=value]'
    exit 1
}

script_dir="$(cd "$(dirname "$0")"; pwd)"
. ${script_dir}/common.sh

# Parse arguments
version=
arch=
base_dir=
parallel=

for option; do
    case $option in
        --version=*)
            version=$(expr "x$option" : "x--version=\(.*\)")
            ;;
        --arch=*)
            arch=$(expr "x$option" : "x--arch=\(.*\)")
            ;;
        --modules-dir=*)
            base_dir=$(expr "x$option" : "x--modules-dir=\(.*\)")
            ;;
        --parallel=*)
            parallel=$(expr "x$option" : "x--parallel=\(.*\)")
            ;;
        *)
            echo "Unknown option: $option" 1>&2
            exit 1
            ;;
    esac
done

if [ -z "${version}" ]; then usage; fi
if [ -z "${base_dir}" ]; then usage; fi

if [ -z "${arch}" ]; then
   arch=linux-gnu
fi

if [[ ! (${arch} = 'linux-gnu' || ${arch} = 'linux-gnu-opt') ]]; then
    usage
fi

parallel="${parallel:-$(nproc)}"

read -r version major minor _ < <(split_version ${version})

# Unsupported versions: https://chaste.github.io/docs/installguides/dependency-versions/
if version_lt "${version}" '3.12'; then  # PETSc < 3.12.x
    echo "$(basename $0): PETSc versions < 3.12 not supported"
    exit 1
fi

# Get tarballs to prevent download errors
mkdir -p ${base_dir}/src/petsc
cd ${base_dir}/src/petsc

download_f2cblaslapack=1
if (version_eq "${major}.${minor}" '3.17'); then # PETSc == 3.17.x
    wget -nc https://www.mcs.anl.gov/petsc/mirror/externalpackages/f2cblaslapack-3.4.2.q4.tar.gz
    download_f2cblaslapack=$(pwd)/f2cblaslapack-3.4.2.q4.tar.gz
fi

# Download and extract PETSc
URL_PETSC=https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-lite-${version}.tar.gz
wget -nc ${URL_PETSC}

install_dir=${base_dir}/opt/petsc/${version}
mkdir -p ${install_dir}

tar -xzf $(basename ${URL_PETSC}) -C ${install_dir} --strip-components=1

# Fix for isAlive() removal from Python 3.9+
# https://bugs.python.org/issue37804
if [[ (${major} -eq 3) && ((${minor} -eq 12) || (${minor} -eq 13)) ]]; then  # PETSc 3.12.x & 3.13.x
    cd ${install_dir}
    sed -i.bak 's/thread.isAlive()/thread.is_alive()/g' config/BuildSystem/script.py
fi

# Build and install
cd ${install_dir}
export PETSC_DIR=$(pwd)

case ${arch} in

    linux-gnu)
        export PETSC_ARCH=linux-gnu
        python3 ./configure \
            --COPTFLAGS=-Og \
            --CXXOPTFLAGS=-Og \
            --download-f2cblaslapack=${download_f2cblaslapack} \
            --download-hypre=1 \
            --download-metis=1 \
            --download-parmetis=1 \
            --with-cc=mpicc \
            --with-cxx=mpicxx \
            --with-debugging=1 \
            --with-fc=0 \
            --with-shared-libraries \
            --with-ssl=false \
            --with-x=false && \
        make -j ${parallel} all
        ;;

    linux-gnu-opt)
        export PETSC_ARCH=linux-gnu-opt
        python3 ./configure \
            --download-f2cblaslapack=${download_f2cblaslapack} \
            --download-hypre=1 \
            --download-metis=1 \
            --download-parmetis=1 \
            --with-cc=mpicc \
            --with-cxx=mpicxx \
            --with-debugging=0 \
            --with-fc=0 \
            --with-shared-libraries \
            --with-ssl=false \
            --with-x=false && \
        make -j ${parallel} all
        ;;
    *)
        ;;
esac

# Add modulefile
mkdir -p ${base_dir}/modulefiles/petsc/${version}
cd  ${base_dir}/modulefiles/petsc/${version}
cat <<EOF > ${arch}
#%Module1.0#####################################################################
###
## petsc ${version}/${arch} modulefile
##
proc ModulesTest { } {
    set paths "[getenv PETSC_DIR]
               [getenv PETSC_DIR]/[getenv PETSC_ARCH]
               [getenv PETSC_DIR]/[getenv PETSC_ARCH]/bin
               [getenv PETSC_DIR]/[getenv PETSC_ARCH]/include
               [getenv PETSC_DIR]/[getenv PETSC_ARCH]/lib
               [getenv PETSC_DIR]/[getenv PETSC_ARCH]/lib/libpetsc.so"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for petsc ${version}, with PETSC_ARCH=${arch}\n"
}

module-whatis "This adds the environment variables for petsc ${version}, with PETSC_ARCH=${arch}"

setenv          PETSC_DIR            ${install_dir}
setenv          PETSC_ARCH           ${arch}

prepend-path    PATH                 ${install_dir}/${arch}/bin

prepend-path    LIBRARY_PATH         ${install_dir}/${arch}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/${arch}/lib
prepend-path    LD_RUN_PATH          ${install_dir}/${arch}/lib

prepend-path    INCLUDE              ${install_dir}/${arch}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/${arch}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/${arch}/include

prepend-path    CMAKE_PREFIX_PATH    ${install_dir}/${arch}

setenv          PARMETIS_ROOT        ${install_dir}/${arch}

conflict petsc
EOF
