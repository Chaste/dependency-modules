#!/bin/bash -eu

# Installs XSD from source and creates a modulefile for it.
# Arguments:
#   --version=version: Version of XSD to install (e.g., 4.0.0)
#   --modules-dir=path: The base directory for the installation and modulefile.
# Example usage:
#   ./install_xsd.sh --version=4.0.0 --modules-dir=/path/to/modules
#   module load xsd/4.0.0

usage()
{
    echo 'Usage: '"$(basename $0)"' --version=version --modules-dir=path'
    exit 1
}

script_dir="$(cd "$(dirname "$0")"; pwd)"
. ${script_dir}/common.sh

# Parse arguments
version=
base_dir=

for option; do
    case $option in
        --version=*)
            version=$(expr "x$option" : "x--version=\(.*\)")
            ;;
        --modules-dir=*)
            base_dir=$(expr "x$option" : "x--modules-dir=\(.*\)")
            ;;
        *)
            echo "Unknown option: $option" 1>&2
            exit 1
            ;;
    esac
done

if [ -z "${version}" ]; then usage; fi
if [ -z "${base_dir}" ]; then usage; fi

read -r version major minor _ < <(split_version ${version})

# Unsupported versions: https://chaste.github.io/docs/installguides/dependency-versions/
if version_lt "${version}" '4.0.0'; then  # XSD < 4.0.0
    echo "$(basename $0): XSD versions < 4.0 not supported"
    exit 1
fi

# Download and install
mkdir -p ${base_dir}/src/xsd
cd ${base_dir}/src/xsd
wget -nc https://www.codesynthesis.com/download/xsd/${major}.${minor}/linux-gnu/x86_64/xsd-${version}-x86_64-linux-gnu.tar.bz2

install_dir=${base_dir}/opt/xsd/${version}
mkdir -p ${install_dir}

tar -xjf xsd-${version}-x86_64-linux-gnu.tar.bz2 -C ${install_dir} --strip-components=1

# Add modulefile
mkdir -p ${base_dir}/modulefiles/xsd
cd  ${base_dir}/modulefiles/xsd
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## xsd ${version} modulefile
##
proc ModulesTest { } {
    set paths "[getenv XSD_ROOT]
               [getenv XSD_ROOT]/bin
               [getenv XSD_ROOT]/libxsd"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for xsd ${version}\n"
}

module-whatis "This adds the environment variables for xsd ${version}"

setenv          XSD_ROOT             ${install_dir}

prepend-path    PATH                 ${install_dir}/bin

prepend-path    INCLUDE              ${install_dir}/libxsd
prepend-path    C_INCLUDE_PATH       ${install_dir}/libxsd
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/libxsd

prepend-path    CMAKE_PREFIX_PATH    ${install_dir}

conflict xsd
EOF
