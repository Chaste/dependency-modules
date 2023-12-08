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

# Modulefile pointing to system version
if [ "$version" = "system" ]; then
    version=$(dpkg -s libsundials-dev | grep 'Version:' | cut -d' ' -f2 | cut -d. -f1,2,3 | cut -d+ -f1)

    mkdir -p ${base_dir}/modulefiles/sundials && cd  ${base_dir}/modulefiles/sundials
    cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## sundials ${version} modulefile
##
proc ModulesTest { } {
    set paths "[getenv SUNDIALS_ROOT]
               [getenv SUNDIALS_ROOT]/include
               [getenv SUNDIALS_ROOT]/lib"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for sundials ${version}\n"
}

module-whatis "This adds the environment variables for sundials ${version}"

setenv          SUNDIALS_ROOT        /usr

prepend-path    LIBRARY_PATH         /usr/lib/x86_64-linux-gnu
prepend-path    LD_LIBRARY_PATH      /usr/lib/x86_64-linux-gnu
prepend-path    LD_RUN_PATH          /usr/lib/x86_64-linux-gnu

prepend-path    INCLUDE              /usr/include/sundials
prepend-path    C_INCLUDE_PATH       /usr/include/sundials
prepend-path    CPLUS_INCLUDE_PATH   /usr/include/sundials

prepend-path    CMAKE_PREFIX_PATH    /usr

conflict sundials
EOF
    exit 0
fi

version_arr=(${version//\./ })
major=${version_arr[0]}
minor=${version_arr[1]}

# Unsupported versions: https://github.com/Chaste/dependency-modules/wiki
if [[ (${major} -lt 2) || ((${major} -eq 2) && (${minor} -lt 7)) ]]; then  # Sundials < 2.7.x
    echo "$(basename $0): Sundials versions < 2.7 not supported"
    exit 1
fi

# Download and extract source
mkdir -p ${base_dir}/src/sundials
cd ${base_dir}/src/sundials
wget -nc https://github.com/LLNL/sundials/releases/download/v${version}/sundials-${version}.tar.gz
tar -xzf sundials-${version}.tar.gz

# Build and install
install_dir=${base_dir}/opt/sundials/${version}
mkdir -p ${install_dir}

cd sundials-${version}
mkdir -p build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=${install_dir} \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DEXAMPLES_ENABLE=OFF .. && \
make -j ${parallel} && \
make install

# Add modulefile
mkdir -p ${base_dir}/modulefiles/sundials
cd  ${base_dir}/modulefiles/sundials
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## sundials ${version} modulefile
##
proc ModulesTest { } {
    set paths "[getenv SUNDIALS_ROOT]
               [getenv SUNDIALS_ROOT]/include
               [getenv SUNDIALS_ROOT]/lib"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for sundials ${version}\n"
}

module-whatis "This adds the environment variables for sundials ${version}"

setenv          SUNDIALS_ROOT        ${install_dir}

prepend-path    LIBRARY_PATH         ${install_dir}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/lib
prepend-path    LD_RUN_PATH          ${install_dir}/lib

prepend-path    INCLUDE              ${install_dir}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/include

prepend-path    CMAKE_PREFIX_PATH    ${install_dir}

conflict sundials
EOF
