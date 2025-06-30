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

mkdir -p ${base_dir}/modulefiles/boost
cd ${base_dir}/modulefiles/boost

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

# HDF5 modulefile stub
hdf5_version=$(dpkg -s libhdf5-openmpi-dev | grep 'Version:' | cut -d' ' -f2 | cut -d. -f1,2,3 | cut -d+ -f1)

mkdir -p ${base_dir}/modulefiles/hdf5/${hdf5_version}
cd  ${base_dir}/modulefiles/hdf5/${hdf5_version}

cat <<EOF > linux-gnu
#%Module1.0#####################################################################
###
## hdf5 ${hdf5_version} modulefile
##
proc ModulesTest { } {
    set paths "/usr/bin/h5pcc
               /usr/include/hdf5
               /usr/lib/x86_64-linux-gnu/hdf5"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for hdf5 ${hdf5_version}\n"
}

module-whatis "This adds the environment variables for hdf5 ${hdf5_version}"

conflict hdf5
EOF

# PETSc modulefile stub
petsc_arch=linux-gnu
petsc_version=$(dpkg -s libpetsc-real-dev | grep 'Version:' | cut -d' ' -f2 | cut -d. -f1,2,3 | cut -d+ -f1)

mkdir -p ${base_dir}/modulefiles/petsc/${petsc_version}
cd  ${base_dir}/modulefiles/petsc/${petsc_version}

cat <<EOF > linux-gnu
#%Module1.0#####################################################################
###
## petsc ${petsc_version}/${petsc_arch} modulefile
##
proc ModulesTest { } {
    set paths "/usr/include/petsc
               /usr/lib/x86_64-linux-gnu/libpetsc.so"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for petsc ${petsc_version} with PETSC_ARCH=${petsc_arch}\n"
}

module-whatis "This adds the environment variables for petsc ${petsc_version} with PETSC_ARCH=${petsc_arch}"

conflict petsc
EOF

# TODO: This adds PETSc/HDF5 modulefile stub as a temporary workaround for backwards compatibility.
# Remove once the combined PETSc/HDF5 module is no longer needed.
# See https://github.com/Chaste/dependency-modules/issues/84

mkdir -p ${base_dir}/modulefiles/petsc_hdf5/${petsc_version}_${hdf5_version}
cd  ${base_dir}/modulefiles/petsc_hdf5/${petsc_version}_${hdf5_version}

cat <<EOF > linux-gnu
#%Module1.0#####################################################################
###
## petsc_hdf5 ${petsc_version}_${hdf5_version}/${petsc_arch} modulefile
##
proc ModulesTest { } {
    set paths "/usr/include/hdf5
               /usr/include/petsc"

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

conflict petsc_hdf5
EOF

# Sundials modulefile stub
version=$(dpkg -s libsundials-dev | grep 'Version:' | cut -d' ' -f2 | cut -d. -f1,2,3 | cut -d+ -f1)

mkdir -p ${base_dir}/modulefiles/sundials
cd  ${base_dir}/modulefiles/sundials

cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## sundials ${version} modulefile
##
proc ModulesTest { } {
    set paths "/usr/include/sundials
               /usr/lib/x86_64-linux-gnu/libsundials_cvode.so"

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

conflict sundials
EOF


# VTK modulefile stub
version=""
for i in $(seq 7 9); do
    version=$(dpkg -s "libvtk${i}-dev" | grep 'Version:' | cut -d' ' -f2 | cut -d. -f1,2,3 | cut -d+ -f1)
    if [ -n "${version}" ]; then
        break;
    fi
done
if [ -z "${version}" ]; then echo "Unknown VTK system version"; exit 1; fi

major=$(echo $version | cut -d. -f1)
minor=$(echo $version | cut -d. -f2)

mkdir -p ${base_dir}/modulefiles/vtk
cd ${base_dir}/modulefiles/vtk

cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## vtk ${version} modulefile
##
proc ModulesTest { } {
    set paths "/usr/include/vtk-${major}.${minor}
               /usr/lib/x86_64-linux-gnu/libvtkCommonCore-${major}.${minor}.so"

    foreach path \$paths {
        if { ![file exists \$path] } {
            puts stderr "ERROR: Does not exist: \$path"
            return 0
        }
    }
    return 1
}

proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for vtk ${version}\n"
}

module-whatis "This adds the environment variables for vtk ${version}"

conflict vtk
EOF


# Xerces-C modulefile stub
version=$(dpkg -s libxerces-c-dev | grep 'Version:' | cut -d' ' -f2 | cut -d. -f1,2,3 | cut -d+ -f1)

mkdir -p ${base_dir}/modulefiles/xercesc
cd  ${base_dir}/modulefiles/xercesc

cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## xercesc ${version} modulefile
##
proc ModulesTest { } {
    set paths "/usr/include/xercesc
               /usr/lib/x86_64-linux-gnu/libxerces-c.so"

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

conflict xercesc
EOF


# XSD modulefile stub
version=$(dpkg -s xsdcxx | grep 'Version:' | cut -d' ' -f2 | cut -d. -f1,2,3 | cut -d- -f1)

mkdir -p ${base_dir}/modulefiles/xsd
cd  ${base_dir}/modulefiles/xsd

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
