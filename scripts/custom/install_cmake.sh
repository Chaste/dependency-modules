#!/bin/bash -eu

# Installs CMake from source and creates a modulefile for it.
# Arguments:
#   --version=version: The CMake version to install (e.g., 3.21.2).
#   --modules-dir=path: The base directory for the installation and modulefile.
#   --parallel=value: The number of parallel jobs to use for building (default: number of CPU cores).
# Example usage:
#   ./install_cmake.sh --version=3.21.2 --modules-dir=/path/to/modules --parallel=4
#   module load cmake/3.21.2

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

# Unsupported versions: https://chaste.github.io/docs/installguides/dependency-versions/
if version_lt "${version}" '3.16.3'; then  # CMake < 3.16.3
    echo "$(basename $0): CMake versions < 3.16.3 not supported"
    exit 1
fi

# Download and extract source
mkdir -p ${base_dir}/src/cmake
cd ${base_dir}/src/cmake
wget -nc https://cmake.org/files/v${major}.${minor}/cmake-${version}.tar.gz
tar -xzf cmake-${version}.tar.gz

# Build and install
install_dir=${base_dir}/opt/cmake/${version}
mkdir -p ${install_dir}

cd cmake-${version}
./bootstrap \
    --prefix=${install_dir} \
    --parallel=${parallel} && \
make -j ${parallel} && \
make install

# Add modulefile
mkdir -p ${base_dir}/modulefiles/cmake
cd  ${base_dir}/modulefiles/cmake
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## cmake ${version} modulefile
##
proc ModulesTest { } {
    set paths "${install_dir}/bin/cmake"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for cmake ${version}\n"
}

module-whatis "This adds the environment variables for cmake ${version}"

prepend-path    PATH    ${install_dir}/bin

conflict cmake
EOF
