#!/bin/bash -eu

usage()
{
    echo 'Usage: '"$(basename $0)"' --petsc-version=version --hdf5-version=version [--mpich-version=version]'
    echo '        --petsc-arch={linux-gnu|linux-gnu-opt} --modules-dir=path [--parallel=value]'
    exit 1
}

# Parse arguments
petsc_version=
petsc_arch=
hdf5_version=
mpich_version=
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
        --mpich-version=*)
            mpich_version=$(expr "x$option" : "x--mpich-version=\(.*\)")
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

parallel="${parallel:-$(nproc)}"

if [[ ! (${petsc_arch} = 'linux-gnu' 
      || ${petsc_arch} = 'linux-gnu-opt') ]]; then
    usage
fi

petsc_version_arr=(${petsc_version//\./ })
petsc_major=${petsc_version_arr[0]}
petsc_minor=${petsc_version_arr[1]}

hdf5_version_arr=(${hdf5_version//\./ })
hdf5_major=${hdf5_version_arr[0]}
hdf5_minor=${hdf5_version_arr[1]}

# Unsupported versions: https://chaste.cs.ox.ac.uk/trac/wiki/InstallGuides/DependencyVersions
if [[ (${petsc_major} -lt 3) || ((${petsc_major} -eq 3) && (${petsc_minor} -lt 7)) ]]; then  # PETSc < 3.7.x
    echo "$(basename $0): PETSc versions < 3.7 not supported"
    exit 1
fi

if [[ (${hdf5_major} -lt 1) || ((${hdf5_major} -eq 1) && (${hdf5_minor} -lt 10)) ]]; then  # HDF5 < 1.10.x
    echo "$(basename $0): HDF5 versions < 1.10 not supported"
    exit 1
fi

# Preferred MPICH versions
URL_MPICH_3_3=https://www.mpich.org/static/downloads/3.3/mpich-3.3.tar.gz
URL_MPICH_3_4=https://www.mpich.org/static/downloads/3.4a3/mpich-3.4a3.tar.gz

# Fixes for broken Hypre links in some PETSc versions
URL_HYPRE_2_11=https://github.com/hypre-space/hypre/archive/refs/tags/v2.11.1.tar.gz
URL_HYPRE_2_12=https://github.com/hypre-space/hypre/archive/refs/tags/v2.12.0.tar.gz
URL_HYPRE_2_14=https://github.com/hypre-space/hypre/archive/refs/tags/v2.14.0.tar.gz
URL_HYPRE_2_15=https://github.com/hypre-space/hypre/archive/refs/tags/v2.15.1.tar.gz

# Retrieving packages to fix "url is not a tarball" errors
mkdir -p ${base_dir}/src/petsc_hdf5
cd ${base_dir}/src/petsc_hdf5

download_hdf5=1
URL_HDF5=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${hdf5_major}.${hdf5_minor}/hdf5-${hdf5_version}/src/hdf5-${hdf5_version}.tar.gz
wget -nc ${URL_HDF5}
download_hdf5=$(pwd)/$(basename ${URL_HDF5})

download_mpich=1
if [ -n "${mpich_version}" ]; then
    URL_MPICH=https://www.mpich.org/static/downloads/${mpich_version}/mpich-${mpich_version}.tar.gz
    wget -nc ${URL_MPICH}
    download_mpich=$(pwd)/$(basename ${URL_MPICH})
fi

download_hypre=1
if [[ (${petsc_major} -eq 3) && (${petsc_minor} -eq 7) ]]; then  # PETSc 3.7.x
    if [ -z "${mpich_version}" ]; then
        wget -nc ${URL_MPICH_3_3}
        download_mpich=$(pwd)/$(basename ${URL_MPICH_3_3})
    fi
    
    wget -nc ${URL_HYPRE_2_11}  # Fixes broken hypre link in this version
    download_hypre=$(pwd)/$(basename ${URL_HYPRE_2_11})

elif [[ (${petsc_major} -eq 3) && (${petsc_minor} -eq 8) ]]; then  # PETSc 3.8.x
    if [ -z "${mpich_version}" ]; then
        wget -nc ${URL_MPICH_3_3}
        download_mpich=$(pwd)/$(basename ${URL_MPICH_3_3})
    fi
    
    wget -nc ${URL_HYPRE_2_12}  # Fixes broken hypre link in this version
    download_hypre=$(pwd)/$(basename ${URL_HYPRE_2_12})

elif [[ (${petsc_major} -eq 3) && (${petsc_minor} -eq 9) ]]; then  # PETSc 3.9.x
    if [ -z "${mpich_version}" ]; then
        wget -nc ${URL_MPICH_3_3}
        download_mpich=$(pwd)/$(basename ${URL_MPICH_3_3})
    fi
    
    wget -nc ${URL_HYPRE_2_14}  # Fixes broken hypre link in this version
    download_hypre=$(pwd)/$(basename ${URL_HYPRE_2_14})

elif [[ (${petsc_major} -eq 3) && (${petsc_minor} -eq 10) ]]; then  # PETSc 3.10.x
    if [ -z "${mpich_version}" ]; then
        wget -nc ${URL_MPICH_3_3}
        download_mpich=$(pwd)/$(basename ${URL_MPICH_3_3})
    fi
    
    wget -nc ${URL_HYPRE_2_14}  # Fixes broken hypre link in this version
    download_hypre=$(pwd)/$(basename ${URL_HYPRE_2_14})
    
elif [[ (${petsc_major} -eq 3) && (${petsc_minor} -eq 11) ]]; then  # PETSc 3.11.x
    if [ -z "${mpich_version}" ]; then
        wget -nc ${URL_MPICH_3_3}
        download_mpich=$(pwd)/$(basename ${URL_MPICH_3_3})
    fi
    
    wget -nc ${URL_HYPRE_2_15}  # Fixes broken hypre link in this version
    download_hypre=$(pwd)/$(basename ${URL_HYPRE_2_15})

elif [[ (${petsc_major} -eq 3) && (${petsc_minor} -eq 12) ]]; then  # PETSc 3.12.x
    if [ -z "${mpich_version}" ]; then
        wget -nc ${URL_MPICH_3_4}
        download_mpich=$(pwd)/$(basename ${URL_MPICH_3_4})
    fi
fi

# Download and extract PETSc
URL_PETSC=https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-${petsc_version}.tar.gz
wget -nc ${URL_PETSC}

install_dir=${base_dir}/opt/petsc_hdf5/${petsc_version}_${hdf5_version}
mkdir -p ${install_dir}

tar -xzf $(basename ${URL_PETSC}) -C ${install_dir} --strip-components=1

# Build and install
cd ${install_dir}
export PETSC_DIR=$(pwd)

case ${petsc_arch} in

    linux-gnu)
        export PETSC_ARCH=linux-gnu
        ./configure \
            --with-make-np=${parallel} \
            --with-cc=gcc \
            --with-cxx=g++ \
            --with-fc=0 \
            --COPTFLAGS=-Og \
            --CXXOPTFLAGS=-Og \
            --with-x=false \
            --with-ssl=false \
            --download-f2cblaslapack=1 \
            --download-mpich=${download_mpich} \
            --download-hdf5=${download_hdf5} \
            --download-parmetis=1 \
            --download-metis=1 \
            --download-hypre=${download_hypre} \
            --with-shared-libraries && \
        make all test
        ;;

    linux-gnu-opt)
        export PETSC_ARCH=linux-gnu-opt
        ./configure \
            --with-make-np=${parallel} \
            --with-cc=gcc \
            --with-cxx=g++ \
            --with-fc=0 \
            --COPTFLAGS=-Og \
            --CXXOPTFLAGS=-Og \
            --with-x=false \
            --with-ssl=false \
            --download-f2cblaslapack=1 \
            --download-mpich=${download_mpich} \
            --download-hdf5=${download_hdf5} \
            --download-parmetis=1 \
            --download-metis=1 \
            --download-hypre=${download_hypre} \
            --with-shared-libraries \
            --with-debugging=0 && \
        make all test
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

setenv          HDF5_ROOT            ${install_dir}/${petsc_arch}
setenv          PARMETIS_ROOT        ${install_dir}/${petsc_arch}

conflict petsc
conflict hdf5
conflict petsc_hdf5
EOF
