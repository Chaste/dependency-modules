#!/bin/bash
set -o errexit
set -o nounset

usage()
{
    echo 'Usage: '"$0"' --version=version --modules-dir=path [--parallel=value]'
    exit 1
}

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

version_arr=(${version//\./ })
major=${version_arr[0]}
minor=${version_arr[1]}

mkdir -p ${base_dir}/src/cmake
cd ${base_dir}/src/cmake
wget -nc https://cmake.org/files/v${major}.${minor}/cmake-${version}.tar.gz
tar -xzf cmake-${version}.tar.gz

install_dir=${base_dir}/opt/cmake/${version}
mkdir -p ${install_dir}

cd cmake-${version}
./bootstrap \
    --prefix=${install_dir} \
    --parallel=${parallel} && \
make -j ${parallel} && \
make install

mkdir -p ${base_dir}/modulefiles/cmake
cd  ${base_dir}/modulefiles/cmake
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## cmake ${version} modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for cmake ${version}\n"
}

module-whatis "This adds the environment variables for cmake ${version}"

prepend-path    PATH    ${install_dir}/bin

conflict cmake
EOF
