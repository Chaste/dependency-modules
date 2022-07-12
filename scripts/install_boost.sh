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
ver_si_on=${version//\./_}  # Converts 1.69.0 to 1_69_0

mkdir -p ${base_dir}/src/boost
cd ${base_dir}/src/boost

if [[ (${major} -lt 1) || ((${major} -eq 1) && (${minor} -le 70)) ]]; then  # Boost <= 1.70.x
    wget -nc https://downloads.sourceforge.net/project/boost/boost/${version}/boost_${ver_si_on}.tar.bz2

else  # Boost > 1.70.x
    wget -nc https://dl.bintray.com/boostorg/release/${version}/source/boost_${ver_si_on}.tar.bz2
fi
tar -xjf boost_${ver_si_on}.tar.bz2

install_dir=${base_dir}/opt/boost/${version}
mkdir -p ${install_dir}

cd boost_${ver_si_on}
if [[ (${major} -lt 1) || ((${major} -eq 1) && (${minor} -le 39)) ]]; then  # Boost <= 1.39.x
    ./configure --prefix=${install_dir} && \
    make -j ${parallel} && \
    make install

elif [ ${major} -eq 1 ] && [ ${minor} -le 49 ]; then  # 1.39.x < Boost <= 1.49.x
    ./bootstrap.sh --prefix=${install_dir} && \
    ./bjam -j ${parallel} install

else  # Boost > 1.49.x
    ./bootstrap.sh --prefix=${install_dir} && \
    ./b2 -j ${parallel} install
fi

if [ ${version} = 1.64.0 ]; then
    # Fix: https://github.com/boostorg/serialization/commit/1d86261581230e2dc5d617a9b16287d326f3e229
    sed -i.bak '25i\#include <boost/serialization/array_wrapper.hpp>' ${install_dir}/include/boost/serialization/array.hpp
fi

mkdir -p ${base_dir}/modulefiles/boost
cd  ${base_dir}/modulefiles/boost
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## boost ${version} modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for boost ${version}\n"
}

module-whatis "This adds the environment variables for boost ${version}"

setenv          BOOST_ROOT           ${install_dir}
prepend-path    CMAKE_PREFIX_PATH    ${install_dir}
prepend-path    LIBRARY_PATH         ${install_dir}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/lib
prepend-path    INCLUDE              ${install_dir}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/include

conflict boost
EOF
