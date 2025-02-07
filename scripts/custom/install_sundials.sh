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

# Unsupported versions: https://chaste.github.io/docs/installguides/dependency-versions/
if [[ (${major} -lt 3) 
  || ((${major} -eq 3) && (${minor} -lt 1)) ]]; then  # Sundials < 3.1.x
    echo "$(basename $0): Sundials versions < 3.1 not supported"
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
    -DENABLE_MPI=ON \
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
