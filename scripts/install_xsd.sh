#!/bin/bash -eu

usage()
{
    echo 'Usage: '"$(basename $0)"' --version=version --modules-dir=path'
    exit 1
}

# Parse arguments
version=
base_dir=

for option; do
    case $option in
        --version=*)
            version=$(expr "x$option" : "x--version=\(.*\)")
            ;;
        --modules-dir=*)
            base_dir=$(expr "x$option" : "x--modules-dir=\(.*\)")
            ;;
        *)
            echo "Unknown option: $option" 1>&2
            exit 1
            ;;
    esac
done

if [ -z "${version}" ]; then usage; fi
if [ -z "${base_dir}" ]; then usage; fi

# Modulefile for system version
if [ "$version" = "system" ]; then
    version=$(dpkg -s xsdcxx | grep 'Version:' | cut -d' ' -f2 | cut -d. -f1,2,3 | cut -d- -f1)
    
    mkdir -p ${base_dir}/modulefiles/xsd && cd  ${base_dir}/modulefiles/xsd
    cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## xsd ${version} modulefile
##
proc ModulesTest { } {
    set paths "/usr/bin/xsdcxx
               /usr/include/xsd"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for xsd ${version}\n"
}

module-whatis "This adds the environment variables for xsd ${version}"

conflict xsd
EOF
    exit 0
fi

version_arr=(${version//\./ })
major=${version_arr[0]}
minor=${version_arr[1]}

# Unsupported versions: https://chaste.github.io/docs/installguides/dependency-versions/
if [ ${major} -lt 4 ]; then  # XSD < 4.0.x
    echo "$(basename $0): XSD versions < 4.0 not supported"
    exit 1
fi

# Download and install
mkdir -p ${base_dir}/src/xsd
cd ${base_dir}/src/xsd
wget -nc https://www.codesynthesis.com/download/xsd/${major}.${minor}/linux-gnu/x86_64/xsd-${version}-x86_64-linux-gnu.tar.bz2

install_dir=${base_dir}/opt/xsd/${version}
mkdir -p ${install_dir}

tar -xjf xsd-${version}-x86_64-linux-gnu.tar.bz2 -C ${install_dir} --strip-components=1

# Add modulefile
mkdir -p ${base_dir}/modulefiles/xsd
cd  ${base_dir}/modulefiles/xsd
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## xsd ${version} modulefile
##
proc ModulesTest { } {
    set paths "[getenv XSD_ROOT]
               [getenv XSD_ROOT]/bin
               [getenv XSD_ROOT]/libxsd"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for xsd ${version}\n"
}

module-whatis "This adds the environment variables for xsd ${version}"

setenv          XSD_ROOT             ${install_dir}

prepend-path    PATH                 ${install_dir}/bin

prepend-path    INCLUDE              ${install_dir}/libxsd
prepend-path    C_INCLUDE_PATH       ${install_dir}/libxsd
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/libxsd

prepend-path    CMAKE_PREFIX_PATH    ${install_dir}

conflict xsd
EOF
