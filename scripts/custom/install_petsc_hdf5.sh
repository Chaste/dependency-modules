#!/bin/bash -eu

usage()
{
    echo 'Usage: '"$(basename $0)"' --petsc-version=version --petsc-arch=[{linux-gnu|linux-gnu-opt}]'
    echo '        --hdf5-version=version --modules-dir=path [--parallel=value]'
    exit 1
}

script_dir="$(cd "$(dirname "$0")"; pwd)"
. ${script_dir}/common.sh

# Parse arguments
petsc_version=
petsc_arch=
hdf5_version=
base_dir=
parallel=

for option; do
    case $option in
        --petsc-version=*)
            petsc_version=$(expr "x$option" : "x--petsc-version=\(.*\)")
            ;;
        --petsc-arch=*)
            petsc_arch=$(expr "x$option" : "x--petsc-arch=\(.*\)")
            ;;
        --hdf5-version=*)
            hdf5_version=$(expr "x$option" : "x--hdf5-version=\(.*\)")
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

if [ -z "${petsc_version}" ]; then usage; fi
if [ -z "${hdf5_version}" ]; then usage; fi
if [ -z "${base_dir}" ]; then usage; fi

if [ -z "${petsc_arch}" ]; then
    petsc_arch=linux-gnu
fi

if [[ ! (${petsc_arch} = 'linux-gnu' || ${petsc_arch} = 'linux-gnu-opt') ]]; then
    usage
fi

parallel="${parallel:-$(nproc)}"

read -r petsc_version petsc_major petsc_minor _ < <(split_version ${petsc_version})

read -r hdf5_version hdf5_major hdf5_minor hdf5_patch < <(split_version ${hdf5_version})
hdf5_ver_si_on=${hdf5_version//\./_}  # Converts 1.14.0 to 1_14_0

# Unsupported versions: https://chaste.github.io/docs/installguides/dependency-versions/
if [[ (${petsc_major} -lt 3) 
  || ((${petsc_major} -eq 3) && (${petsc_minor} -lt 12)) ]]; then  # PETSc < 3.12.x
    echo "$(basename $0): PETSc versions < 3.12 not supported"
    exit 1
fi

if [[ (${hdf5_major} -lt 1)  # HDF5 < 1.x
   || ((${hdf5_major} -eq 1) && (${hdf5_minor} -lt 10))  # HDF5 < 1.10.x
   || ((${hdf5_major} -eq 1) && (${hdf5_minor} -eq 10) && (${hdf5_patch} -lt 4))  # HDF5 < 1.10.4
   || ((${hdf5_major} -eq 1) && (${hdf5_minor} -eq 11))  # HDF5 == 1.11.x
   || ((${hdf5_major} -eq 1) && (${hdf5_minor} -eq 13))  # HDF5 == 1.13.x
   ]]; then
    echo "$(basename $0): HDF5 versions < 1.10.4 not supported"
    exit 1
fi

# Retrieve packages to fix "url is not a tarball" errors
mkdir -p ${base_dir}/src/petsc_hdf5
cd ${base_dir}/src/petsc_hdf5

download_hdf5=1
URL_HDF5=
if [[ ((${hdf5_major} -eq 1) && (${hdf5_minor} -eq 10) && (${hdf5_patch} -lt 12))  # HDF5 >=1.10.0, <1.10.12
   || ((${hdf5_major} -eq 1) && (${hdf5_minor} -eq 12) && (${hdf5_patch} -lt 2))   # HDF5 >=1.12.0, <1.12.2
   ]]; then
    URL_HDF5=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${hdf5_major}.${hdf5_minor}/hdf5-${hdf5_version}/src/hdf5-${hdf5_version}.tar.gz

elif [[ (${hdf5_major} -eq 1) && (${hdf5_minor} -eq 12) && (${hdf5_patch} -lt 4) # HDF5 >=1.12.2, <1.12.4
     || (${hdf5_major} -eq 1) && (${hdf5_minor} -eq 14) && (${hdf5_patch} -lt 4) # HDF5 >=1.14.0, <1.14.4
     ]]; then
    URL_HDF5=https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-${hdf5_ver_si_on}.tar.gz

else
    # HDF5 >=1.10.12, <1.12
    # HDF5 >=1.12.4, <1.13
    # HDF5 >=1.14.4, <1.15
    # + catch-all
    URL_HDF5=https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-${hdf5_version}.tar.gz
fi

wget -nc ${URL_HDF5}
download_hdf5=$(pwd)/$(basename ${URL_HDF5})

# Download and extract PETSc
URL_PETSC=https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-lite-${petsc_version}.tar.gz
wget -nc ${URL_PETSC}

install_dir=${base_dir}/opt/petsc_hdf5/${petsc_version}_${hdf5_version}
mkdir -p ${install_dir}

tar -xzf $(basename ${URL_PETSC}) -C ${install_dir} --strip-components=1

# Fix for isAlive() removal from Python 3.9+
# https://bugs.python.org/issue37804
if [[ (${petsc_major} -eq 3) && ((${petsc_minor} -eq 12) || (${petsc_minor} -eq 13)) ]]; then  # PETSc 3.12.x & 3.13.x
    cd ${install_dir}
    sed -i.bak 's/thread.isAlive()/thread.is_alive()/g' config/BuildSystem/script.py
fi

# Build and install
cd ${install_dir}
export PETSC_DIR=$(pwd)

case ${petsc_arch} in

    linux-gnu)
        export PETSC_ARCH=linux-gnu
        python3 ./configure \
            --COPTFLAGS=-Og \
            --CXXOPTFLAGS=-Og \
            --download-f2cblaslapack=1 \
            --download-hdf5=${download_hdf5} \
            --download-hypre=1 \
            --download-metis=1 \
            --download-mpich=1 \
            --download-parmetis=1 \
            --with-cc=gcc \
            --with-cxx=g++ \
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
            --download-f2cblaslapack=1 \
            --download-hdf5=${download_hdf5} \
            --download-hypre=1 \
            --download-metis=1 \
            --download-mpich=1 \
            --download-parmetis=1 \
            --with-cc=gcc \
            --with-cxx=g++ \
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
mkdir -p ${base_dir}/modulefiles/petsc_hdf5/${petsc_version}_${hdf5_version}
cd  ${base_dir}/modulefiles/petsc_hdf5/${petsc_version}_${hdf5_version}
cat <<EOF > ${petsc_arch}
#%Module1.0#####################################################################
###
## petsc_hdf5 ${petsc_version}_${hdf5_version}/${petsc_arch} modulefile
##
proc ModulesTest { } {
    set paths "[getenv PETSC_DIR]
               [getenv PETSC_DIR]/[getenv PETSC_ARCH]
               [getenv PETSC_DIR]/[getenv PETSC_ARCH]/bin
               [getenv PETSC_DIR]/[getenv PETSC_ARCH]/bin/h5pcc
               [getenv PETSC_DIR]/[getenv PETSC_ARCH]/include
               [getenv PETSC_DIR]/[getenv PETSC_ARCH]/lib
               [getenv PETSC_DIR]/[getenv PETSC_ARCH]/lib/libhdf5.so
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
    puts stderr "\tThis adds the environment variables for petsc ${petsc_version} and hdf5 ${hdf5_version}, with PETSC_ARCH=${petsc_arch}\n"
}

module-whatis "This adds the environment variables for petsc ${petsc_version} and hdf5 ${hdf5_version}, with PETSC_ARCH=${petsc_arch}"

setenv          PETSC_DIR            ${install_dir}
setenv          PETSC_ARCH           ${petsc_arch}

prepend-path    PATH                 ${install_dir}/${petsc_arch}/bin

prepend-path    LIBRARY_PATH         ${install_dir}/${petsc_arch}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/${petsc_arch}/lib
prepend-path    LD_RUN_PATH          ${install_dir}/${petsc_arch}/lib

prepend-path    INCLUDE              ${install_dir}/${petsc_arch}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/${petsc_arch}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/${petsc_arch}/include

prepend-path    CMAKE_PREFIX_PATH    ${install_dir}/${petsc_arch}

setenv          HDF5_ROOT            ${install_dir}/${petsc_arch}
setenv          PARMETIS_ROOT        ${install_dir}/${petsc_arch}

conflict petsc
conflict hdf5
conflict petsc_hdf5
EOF
