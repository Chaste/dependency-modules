#!/bin/bash -eu

usage()
{
    echo 'Usage: '"$(basename $0)"' --version=version --modules-dir=path [--parallel=value]'
    exit 1
}

script_dir="$(cd "$(dirname "$0")"; pwd)"

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
ver_si_on=${version//\./_}  # Converts 1.74.0 to 1_74_0

# Unsupported versions: https://chaste.github.io/docs/installguides/dependency-versions/
if [[ (${major} -lt 1) || ((${major} -eq 1) && (${minor} -lt 67)) ]]; then  # Boost < 1.67.x
    echo "$(basename $0): Boost versions < 1.67 not supported"
    exit 1
fi

# Download and extract source
mkdir -p ${base_dir}/src/boost
cd ${base_dir}/src/boost

wget -nc https://archives.boost.io/release/${version}/source/boost_${ver_si_on}.tar.bz2
tar -xjf boost_${ver_si_on}.tar.bz2

src_dir="$(pwd)/boost_${ver_si_on}"

# Fix for Python 3.10+ in Boost <= 1.86.x
# https://github.com/boostorg/python/commit/cbd2d9f033c61d29d0a1df14951f4ec91e7d05cd
if [[ (${major} -eq 1) && (${minor} -le 86) ]]; then  # Boost <= 1.86.x
    cd ${src_dir}/libs/python/src
    sed -i.bak 's#_Py_fopen#fopen#g' exec.cpp
fi

# Patch for Python 3.7+ in Boost <= 1.66.x
 # https://github.com/boostorg/python/commit/660487c43fde76f3e64f1cb2e644500da92fe582
 if [[ (${major} -eq 1) && (${minor} -le 66) ]]; then  # Boost <= 1.66.x
     cd ${src_dir}/libs/python
     patch -t -p1 < ${script_dir}/patches/boost/1.66/boost_166-python37-unicode-as-string.patch
 fi

 # Patch for serialization in Boost <= 1.64.x
 # https://github.com/boostorg/serialization/commit/1d86261581230e2dc5d617a9b16287d326f3e229
 if [[ (${major} -eq 1) && (${minor} -le 64) ]]; then  # Boost <= 1.64.x
     cd ${src_dir}
     patch -t -p2 < ${script_dir}/patches/boost/1.64/boost_164-serialization-array-wrapper.patch
 fi

 # Patch for pthread in 1.69.x <= Boost <= 1.72.x
 # https://github.com/boostorg/thread/pull/297/commits/74fb0a26099bc51d717f5f154b37231ce7df3e98
 if [[ (${major} -eq 1) && (${minor} -ge 69) && (${minor} -le 72) ]]; then  # 1.69.x <= Boost <= 1.72.x
     cd ${src_dir}
     patch -t -p2 < ${script_dir}/patches/boost/1.69/boost_169-pthread.patch
 fi

# Build and install
install_dir=${base_dir}/opt/boost/${version}
mkdir -p ${install_dir}

cd ${src_dir}
./bootstrap.sh --prefix=${install_dir} && \
./b2 -j ${parallel} toolset=gcc cxxflags=-w install

# Add modulefile
mkdir -p ${base_dir}/modulefiles/boost
cd  ${base_dir}/modulefiles/boost
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## boost ${version} modulefile
##
proc ModulesTest { } {
    set paths "[getenv BOOST_ROOT]
               [getenv BOOST_ROOT]/lib
               [getenv BOOST_ROOT]/include"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for boost ${version}\n"
}

module-whatis "This adds the environment variables for boost ${version}"

setenv          BOOST_ROOT           ${install_dir}
setenv          BOOST_DIR            ${install_dir}

prepend-path    LIBRARY_PATH         ${install_dir}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/lib
prepend-path    LD_RUN_PATH          ${install_dir}/lib

prepend-path    INCLUDE              ${install_dir}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/include

prepend-path    CMAKE_PREFIX_PATH    ${install_dir}

conflict boost
EOF
