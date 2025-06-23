#!/bin/bash -eu

# TODO: This script adds a PETSc/HDF5 modulefile as a temporary workaround for backwards compatibility.
# Remove once the combined PETSc/HDF5 module is no longer needed.

usage()
{
    echo 'Usage: '"$(basename $0)"' --petsc-version=version --petsc-arch=[{linux-gnu|linux-gnu-opt}]'
    echo '        --hdf5-version=version --modules-dir=path'
    exit 1
}

script_dir="$(cd "$(dirname "$0")"; pwd)"
. ${script_dir}/common.sh

# Parse arguments
petsc_version=
petsc_arch=
hdf5_version=
base_dir=

for option; do
    case $option in
        --petsc-version=*)
            petsc_version=$(expr "x$option" : "x--petsc-version=\(.*\)")
            ;;
        --petsc-arch=*)
            petsc_arch=$(expr "x$option" : "x--petsc-arch=\(.*\)")
            ;;
        --hdf5-version=*)
            hdf5_version=$(expr "x$option" : "x--hdf5-version=\(.*\)")
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

if [ -z "${petsc_version}" ]; then usage; fi
if [ -z "${hdf5_version}" ]; then usage; fi
if [ -z "${base_dir}" ]; then usage; fi

if [ -z "${petsc_arch}" ]; then
    petsc_arch=linux-gnu
fi

if [[ ! (${petsc_arch} = 'linux-gnu' || ${petsc_arch} = 'linux-gnu-opt') ]]; then
    usage
fi

read -r petsc_version _ < <(split_version ${petsc_version})

read -r hdf5_version _ < <(split_version ${hdf5_version})

# Add modulefile
mkdir -p ${base_dir}/modulefiles/petsc_hdf5/${petsc_version}_${hdf5_version}
cd  ${base_dir}/modulefiles/petsc_hdf5/${petsc_version}_${hdf5_version}
cat <<EOF > ${petsc_arch}
#%Module1.0#####################################################################
###
## petsc_hdf5 ${petsc_version}_${hdf5_version}/${petsc_arch} modulefile
##
proc ModulesTest { } {
    set paths "[getenv HDF5_ROOT]
               [getenv PETSC_DIR]/[getenv PETSC_ARCH]"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for petsc ${petsc_version} and hdf5 ${hdf5_version}, with PETSC_ARCH=${petsc_arch}\n"
}

module-whatis "This adds the environment variables for petsc ${petsc_version} and hdf5 ${hdf5_version}, with PETSC_ARCH=${petsc_arch}"

module load hdf5/${hdf5_version}
module load petsc/${petsc_version}/${petsc_arch}

conflict petsc_hdf5
EOF
