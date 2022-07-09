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

[ -z "${version}" ] && usage
[ -z "${base_dir}" ] && usage
[ -z "x${parallel}" ] && parallel=$(nproc)

version_arr=(${version//\./ })
major=${version_arr[0]}

mkdir -p ${base_dir}/src/python
cd ${base_dir}/src/python
wget -nc https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz
tar -xf Python-${version}.tar.xz
cd Python-${version}

install_dir=${base_dir}/opt/python/${version}
mkdir -p ${install_dir}

./configure \
    --enable-optimizations \
    --prefix=${install_dir} && \
make -j ${parallel} && \
make install

if [ ${major} -eq 3 ]; then
    cd ${install_dir}/bin
    if [ ! -f python]; then
        ln -s python3 python
    fi
    if [ ! -f pip]; then
        ln -s pip3 pip
    fi
fi

mkdir -p ${base_dir}/modulefiles/python
cd  ${base_dir}/modulefiles/python
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## python ${version} modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for python ${version}\n"
}

module-whatis "This adds the environment variables for python ${version}"

prepend-path    PATH    ${install_dir}/bin

conflict python
EOF