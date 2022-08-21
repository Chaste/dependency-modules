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

ver_si_on=${version//\./_}  # Converts 3.1.1 to 3_1_1
version_arr=(${version//\./ })
major=${version_arr[0]}
minor=${version_arr[1]}

# Unsupported versions: https://chaste.cs.ox.ac.uk/trac/wiki/InstallGuides/DependencyVersions
if [[ (${major} -lt 3) || ((${major} -eq 3) && (${minor} -lt 2)) ]]; then  # Xerces-C < 3.2.x
    echo "$(basename $0): Xerces-C versions < 3.2 not supported"
    exit 1
fi

# Download, build and install
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

# Add modulefile
mkdir -p ${base_dir}/modulefiles/xercesc
cd  ${base_dir}/modulefiles/xercesc
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## xercesc ${version} modulefile
##
proc ModulesTest { } {
    set paths "[getenv XERCESC_ROOT]
               [getenv XERCESC_INCLUDE]
               [getenv XERCESC_LIBRARY]"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for xercesc ${version}\n"
}

module-whatis "This adds the environment variables for xercesc ${version}"

setenv          XERCESC_ROOT         ${install_dir}
setenv          XERCESC_INCLUDE      ${install_dir}/include
setenv          XERCESC_LIBRARY      ${install_dir}/lib

prepend-path    LIBRARY_PATH         ${install_dir}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/lib
prepend-path    LD_RUN_PATH          ${install_dir}/lib

prepend-path    INCLUDE              ${install_dir}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/include

prepend-path    CMAKE_PREFIX_PATH    ${install_dir}

conflict xercesc
EOF
