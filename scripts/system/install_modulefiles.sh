#!/bin/bash -eu

# Add modulefile stubs for Ubuntu system dependency versions

usage()
{
    echo 'Usage: '"$(basename $0)"' --modules-dir=path'
    exit 1
}

# Parse arguments
base_dir=

for option; do
    case $option in
        --modules-dir=*)
            base_dir=$(expr "x$option" : "x--modules-dir=\(.*\)")
            ;;
        *)
            echo "Unknown option: $option" 1>&2
            exit 1
            ;;
    esac
done

if [ -z "${base_dir}" ]; then usage; fi

# Boost modulefile stub
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

conflict boost
EOF
