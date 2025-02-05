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

# Modulefile for system version
if [ "$version" = "system" ]; then
    version=$(dpkg -s libboost-dev | grep 'Version:' | cut -d' ' -f2 | cut -d. -f1,2,3)

    mkdir -p ${base_dir}/modulefiles/boost && cd  ${base_dir}/modulefiles/boost
    cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## boost ${version} modulefile
##
proc ModulesTest { } {
    set paths "/usr/include/boost
               /usr/lib/x86_64-linux-gnu/libboost_serialization.so"

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

setenv          Boost_NO_BOOST_CMAKE     OFF
setenv          Boost_NO_SYSTEM_PATHS    OFF

conflict boost
EOF
    exit 0
fi

version_arr=(${version//\./ })
major=${version_arr[0]}
minor=${version_arr[1]}
ver_si_on=${version//\./_}  # Converts 1.74.0 to 1_74_0

# Unsupported versions: https://chaste.github.io/docs/installguides/dependency-versions/
if [[ (${major} -lt 1) || ((${major} -eq 1) && (${minor} -lt 67)) ]]; then  # Boost < 1.74.x
    echo "$(basename $0): Boost versions < 1.74 not supported"
    exit 1
fi

# Download and extract source
mkdir -p ${base_dir}/src/boost
cd ${base_dir}/src/boost

wget -nc https://archives.boost.io/release/${version}/source/boost_${ver_si_on}.tar.bz2
tar -xjf boost_${ver_si_on}.tar.bz2

src_dir="$(pwd)/boost_${ver_si_on}"

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

setenv          Boost_NO_BOOST_CMAKE     ON
setenv          Boost_NO_SYSTEM_PATHS    ON

conflict boost
EOF
