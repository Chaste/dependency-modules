#!/bin/bash -eu

usage()
{
    echo 'Usage: '"$(basename $0)"' --version=version --modules-dir=path [--parallel=value]'
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

# Unsupported versions: https://chaste.cs.ox.ac.uk/trac/wiki/InstallGuides/DependencyVersions
if [[ (${major} -lt 1) || ((${major} -eq 1) && (${minor} -lt 62)) ]]; then  # Boost < 1.62.x
    echo "$(basename $0): Boost versions < 1.62 not supported"
    exit 1
fi

# Download and extract source
mkdir -p ${base_dir}/src/boost
cd ${base_dir}/src/boost

if [[ (${major} -eq 1) && (${minor} -eq 62) ]]; then  # Boost == 1.62.x
    wget -nc https://downloads.sourceforge.net/project/boost/boost/${version}/boost_${ver_si_on}.tar.bz2

else  # Boost > 1.62.x
    wget -nc https://boostorg.jfrog.io/artifactory/main/release/${version}/source/boost_${ver_si_on}.tar.bz2
fi
tar -xjf boost_${ver_si_on}.tar.bz2

# Build and install
install_dir=${base_dir}/opt/boost/${version}
mkdir -p ${install_dir}

cd boost_${ver_si_on}
./bootstrap.sh --prefix=${install_dir} && \
./b2 -j ${parallel} install --with-filesystem

if [ ${version} = 1.64.0 ]; then
    # Fix: https://github.com/boostorg/serialization/commit/1d86261581230e2dc5d617a9b16287d326f3e229
    sed -i.bak '25i\#include <boost/serialization/array_wrapper.hpp>' ${install_dir}/include/boost/serialization/array.hpp
fi

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
prepend-path    LIBRARY_PATH         ${install_dir}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/lib
prepend-path    INCLUDE              ${install_dir}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/include

conflict boost
EOF
