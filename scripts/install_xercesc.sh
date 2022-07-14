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

ver_si_on=${version//\./_}  # Converts 3.1.1 to 3_1_1
version_arr=(${version//\./ })
major=${version_arr[0]}

mkdir -p ${base_dir}/src/xercesc
cd ${base_dir}/src/xercesc

install_dir=${base_dir}/opt/xercesc/${version}
mkdir -p ${install_dir}

if [ ${major} -le 2 ]; then
    wget -nc https://archive.apache.org/dist/xerces/c/${major}/sources/xerces-c-src_${ver_si_on}.tar.gz
    tar -xzf xerces-c-src_${ver_si_on}.tar.gz
    cd xerces-c-src_${ver_si_on}
    export XERCESCROOT=$(pwd)
    cd src/xercesc
    ./runConfigure -plinux -cgcc -xg++ -P${install_dir} && \
    make -j ${parallel} && \
    make install
else
    wget -nc https://archive.apache.org/dist/xerces/c/${major}/sources/xerces-c-${version}.tar.gz
    tar -xzf xerces-c-${version}.tar.gz
    cd xerces-c-${version}
    ./configure --enable-netaccessor-socket --prefix=${install_dir} && \
    make -j ${parallel} && \
    make install
fi

mkdir -p ${base_dir}/modulefiles/xercesc
cd  ${base_dir}/modulefiles/xercesc
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## xercesc ${version} modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for xercesc ${version}\n"
}

module-whatis "This adds the environment variables for xercesc ${version}"

setenv          XERCESCROOT          ${install_dir}
setenv          XERCESC_ROOT         ${install_dir}
prepend-path    CMAKE_PREFIX_PATH    ${install_dir}
prepend-path    PATH                 ${install_dir}/bin
prepend-path    LIBRARY_PATH         ${install_dir}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/lib
prepend-path    INCLUDE              ${install_dir}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/include

conflict xercesc
EOF
