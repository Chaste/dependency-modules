#!/bin/bash
set -o errexit
set -o nounset

usage()
{
    echo 'Usage: '"$(basename $0)"' --version=version --modules-dir=path'
    exit 1
}

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

version_arr=(${version//\./ })
major=${version_arr[0]}
minor=${version_arr[1]}

# Unsupported versions: https://chaste.cs.ox.ac.uk/trac/wiki/InstallGuides/DependencyVersions
if [ ${major} -lt 4 ]; then  # XSD < 4.0.x
    echo "$(basename $0): XSD versions < 4.0 not supported"
    exit 1
fi

mkdir -p ${base_dir}/src/xsd
cd ${base_dir}/src/xsd
wget -nc https://www.codesynthesis.com/download/xsd/${major}.${minor}/linux-gnu/x86_64/xsd-${version}-x86_64-linux-gnu.tar.bz2

install_dir=${base_dir}/opt/xsd/${version}
mkdir -p ${install_dir}

tar -xjf xsd-${version}-x86_64-linux-gnu.tar.bz2 -C ${install_dir} --strip-components=1

mkdir -p ${base_dir}/modulefiles/xsd
cd  ${base_dir}/modulefiles/xsd
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## xsd ${version} modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for xsd ${version}\n"
}

module-whatis "This adds the environment variables for xsd ${version}"

setenv          XSD_ROOT             ${install_dir}
prepend-path    CMAKE_PREFIX_PATH    ${install_dir}
prepend-path    PATH                 ${install_dir}/bin
prepend-path    LIBRARY_PATH         ${install_dir}/libxsd
prepend-path    LD_LIBRARY_PATH      ${install_dir}/libxsd

conflict xsd
EOF
