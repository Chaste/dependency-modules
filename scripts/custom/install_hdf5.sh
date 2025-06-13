#!/bin/bash -eu

# Installs HDF5 from source and creates a modulefile for it.
# Arguments:
#   --version=version: The HDF5 version to install (e.g., 1.12.0).
#   --modules-dir=path: The base directory for the installation and modulefile.
#   --parallel=value: The number of parallel jobs to use for building (default: number of CPU cores).
# Example usage:
#   ./install_hdf5.sh --version=1.12.0 --modules-dir=/path/to/modules --parallel=4
#   module load hdf5/1.12.0

usage()
{
    echo 'Usage: '"$(basename $0)"' --version=version --modules-dir=path [--parallel=value]'
    exit 1
}

script_dir="$(cd "$(dirname "$0")"; pwd)"
. ${script_dir}/../common.sh

# Parse arguments
version=
base_dir=
parallel=

for option; do
    case $option in
        --version=*)
            version=$(expr "x$option" : "x--version=\(.*\)")
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

parallel="${parallel:-$(nproc)}"

read -r version major minor _ < <(split_version ${version})
ver_si_on=${version//\./_}  # Converts 1.14.0 to 1_14_0

# Unsupported versions: https://chaste.github.io/docs/installguides/dependency-versions/
if version_lt "${version}" '1.10.4'; then  # HDF5 < 1.10.4
    echo "$(basename $0): HDF5 versions < 1.10.4 not supported"
    exit 1
fi

if version_eq "${major}.${minor}" '1.11'; then  # HDF5 == 1.11.x
    echo "$(basename $0): HDF5 1.11.x not supported"
    exit 1
fi

if version_eq "${major}.${minor}" '1.13'; then  # HDF5 == 1.13.x
    echo "$(basename $0): HDF5 1.13.x not supported"
    exit 1
fi

# Download and extract source
mkdir -p ${base_dir}/src/hdf5
cd ${base_dir}/src/hdf5

URL_HDF5=
if (version_ge "${version}" '1.10.0' && version_lt "${version}" '1.10.12') ||  # HDF5 >=1.10.0, <1.10.12
   (version_ge "${version}" '1.12.0' && version_lt "${version}" '1.12.2')      # HDF5 >=1.12.0, <1.12.2
then
    URL_HDF5=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${major}.${minor}/hdf5-${version}/src/hdf5-${version}.tar.gz

elif (version_ge "${version}" '1.12.2' && version_lt "${version}" '1.12.4') ||  # HDF5 >=1.12.2, <1.12.4
     (version_ge "${version}" '1.14.0' && version_lt "${version}" '1.14.4')     # HDF5 >=1.14.0, <1.14.4
then
    URL_HDF5=https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-${ver_si_on}.tar.gz

else
    # HDF5 >=1.10.12, <1.11
    # HDF5 >=1.12.4, <1.13
    # HDF5 >=1.14.4, <1.15
    # + catch-all
    URL_HDF5=https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-${version}.tar.gz
fi

src_dir=$(pwd)/hdf5-${version}
mkdir -p ${src_dir}

wget -nc ${URL_HDF5}
tar -xzf $(basename ${URL_HDF5}) -C ${src_dir} --strip-components=1

# Build and install
install_dir=${base_dir}/opt/hdf5/${version}
mkdir -p ${install_dir}

cd ${src_dir}
mkdir -p build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${install_dir} \
    -DHDF5_BUILD_TOOLS=OFF \
    -DHDF5_ENABLE_PARALLEL=ON \
    -DHDF5_ENABLE_Z_LIB_SUPPORT=ON \
    -DHDF5_ENABLE_SZIP_SUPPORT=ON \
    -DHDF5_ENABLE_UNSUPPORTED=OFF .. && \
make -j ${parallel} && \
make install

# Add modulefile
mkdir -p ${base_dir}/modulefiles/hdf5/${version}
cd  ${base_dir}/modulefiles/hdf5/${version}
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## hdf5 ${version} modulefile
##
proc ModulesTest { } {
    set paths "[getenv HDF5_ROOT]
               [getenv HDF5_ROOT]/bin/h5pcc
               [getenv HDF5_ROOT]/include
               [getenv HDF5_ROOT]/lib
               [getenv HDF5_ROOT]/lib/libhdf5.so"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for hdf5 ${version}\n"
}

module-whatis "This adds the environment variables for hdf5 ${version}"

setenv          HDF5_ROOT            ${install_dir}

prepend-path    PATH                 ${install_dir}/bin

prepend-path    LIBRARY_PATH         ${install_dir}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/lib
prepend-path    LD_RUN_PATH          ${install_dir}/lib

prepend-path    INCLUDE              ${install_dir}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/include

prepend-path    CMAKE_PREFIX_PATH    ${install_dir}

conflict hdf5
EOF
