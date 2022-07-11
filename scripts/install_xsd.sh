#!/bin/bash
set -o errexit
set -o nounset

usage()
{
    echo 'Usage: '"$0"' --version=version --modules-dir=path'
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

[ -z "${version}" ] && usage
[ -z "${base_dir}" ] && usage

version_arr=(${version//\./ })
major=${version_arr[0]}
minor=${version_arr[1]}

mkdir -p ${base_dir}/src/xsd
cd ${base_dir}/src/xsd
wget -nc https://chaste.cs.ox.ac.uk/public/deps/xsd-setg.patch
wget -nc https://www.codesynthesis.com/download/xsd/${major}.${minor}/linux-gnu/x86_64/xsd-${version}-x86_64-linux-gnu.tar.bz2

install_dir=${base_dir}/opt/xsd/${version}
mkdir -p ${install_dir}

tar -xjf xsd-${version}-x86_64-linux-gnu.tar.bz2 -C ${install_dir} --strip-components=1

if [ ${major} -eq 3 ]; then
    cd ${install_dir}
    patch -p0 <${base_dir}/src/xsd/xsd-setg.patch
fi

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
