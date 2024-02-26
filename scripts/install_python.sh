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
if [[ (${major} -eq 3) && (${minor} -lt 6) ]]; then  # Python3 < 3.6.x
    echo "$(basename $0): Python3 versions < 3.6 not supported"
    exit 1
fi

# PETSc versions < 3.11.x need Python2 to configure builds
if [[ (${major} -eq 2) && (${minor} -lt 7) ]]; then  # Python2 < 2.7.x
    echo "$(basename $0): Python2 versions < 2.7 not supported (for building dependencies)"
    exit 1
fi

# Download and extract source
mkdir -p ${base_dir}/src/python
cd ${base_dir}/src/python
wget -nc https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz
tar -xf Python-${version}.tar.xz

# Build and install
install_dir=${base_dir}/opt/python/${version}
mkdir -p ${install_dir}

cd Python-${version}
./configure \
     --enable-optimizations \
     --prefix=${install_dir} && \
make -j ${parallel} && \
make install

# Add symbolic links
if [ ${major} -eq 3 ]; then
    cd ${install_dir}/bin
    if [ ! -f python]; then
        ln -s python3 python
    fi
    if [ ! -f pip]; then
        ln -s pip3 pip
    fi
fi

# Add modulefile
mkdir -p ${base_dir}/modulefiles/python
cd  ${base_dir}/modulefiles/python
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## python ${version} modulefile
##
proc ModulesTest { } {
    set paths "${install_dir}/bin/python"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for python ${version}\n"
}

module-whatis "This adds the environment variables for python ${version}"

prepend-path    PATH    ${install_dir}/bin

conflict python
EOF
