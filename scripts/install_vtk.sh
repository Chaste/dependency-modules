#!/bin/bash -eu

usage()
{
    echo 'Usage: '"$(basename $0)"' --version=version --modules-dir=path [--parallel=value]'
    exit 1
}

script_dir="$(cd "$(dirname "$0")"; pwd)"

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
    version=""
    for i in 9 8 7 6
    do
        version=$(dpkg -s "libvtk${i}-dev" | grep 'Version:' | cut -d' ' -f2 | cut -d. -f1,2,3 | cut -d+ -f1)
        if [ -n "${version}" ]; then break; fi
    done

    if [ -z "${version}" ]; then echo "Unknown VTK system version"; exit 1; fi
    
    major=$(echo $version | cut -d. -f1)
    minor=$(echo $version | cut -d. -f2)

    mkdir -p ${base_dir}/modulefiles/vtk && cd  ${base_dir}/modulefiles/vtk
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
    exit 0
fi

version_arr=(${version//\./ })
major=${version_arr[0]}
minor=${version_arr[1]}

# Unsupported versions: https://chaste.github.io/docs/installguides/dependency-versions/
if [[ (${major} -lt 6) 
  || ((${major} -eq 6) && (${minor} -lt 3)) ]]; then  # VTK < 6.3.x
    echo "$(basename $0): VTK versions < 6.3 not supported"
    exit 1
fi

# Download and extract source
mkdir -p ${base_dir}/src/vtk
cd ${base_dir}/src/vtk

src_dir=$(pwd)/VTK-${version}
mkdir -p ${src_dir}

if [[ ${major} -lt 6 || (${major} -eq 6 && ${minor} -eq 0) ]]; then  # VTK <= 6.0.x
    wget -nc http://www.vtk.org/files/release/${major}.${minor}/vtk-${version}.tar.gz
    tar -xzf vtk-${version}.tar.gz -C ${src_dir} --strip-components=1

else  # VTK > 6.0.x
    wget -nc https://github.com/Kitware/VTK/archive/v${version}.tar.gz
    tar -xzf v${version}.tar.gz -C ${src_dir} --strip-components=1
fi

# VTK 6.3.x patches: https://sources.debian.org/patches/vtk6/6.3.0%2Bdfsg2-8.1/
if [[ ${major} -eq 6 && ${minor} -eq 3 ]]; then  # VTK == 6.3.x
    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/vtk6.3.patch
fi

# VTK 7.1.x patches: https://sources.debian.org/patches/vtk7/7.1.1%2Bdfsg2-10.2/
if [[ ${major} -eq 7 && ${minor} -eq 1 ]]; then  # VTK == 7.1.x
    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/vtk7.1.patch
fi

# VTK 8.2.x patches: https://sources.debian.org/patches/vtk7/7.1.1%2Bdfsg2-10.2/
if [[ ${major} -eq 8 && ${minor} -eq 2 ]]; then  # VTK == 8.2.x
    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/vtk8.2.patch
fi

# VTK 9.0.x patches: https://sources.debian.org/patches/vtk9/9.0.1%2Bdfsg1-8/
if [[ ${major} -eq 9 && ${minor} -eq 0 ]]; then  # VTK == 9.0.x
    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/vtk9.0-fix-limits.patch
fi

# VTK 9.1.x patches: https://sources.debian.org/patches/vtk9/9.1.0%2Breally9.1.0%2Bdfsg2-7.1/
if [[ ${major} -eq 9 && ${minor} -eq 1 ]]; then  # VTK == 9.1.x
    cd ${script_dir}/patches

    wget https://sources.debian.org/data/main/v/vtk9/9.1.0%2Breally9.1.0%2Bdfsg2-7.1/debian/patches/gcc-13.patch
    echo "0f7cb1212efe58cf87d4b0b46afbdd02a83643721e0abb4e280679d2c392f51b  gcc-13.patch" | sha256sum -c

    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/gcc-13.patch
fi

# VTK 9.2.x patches: https://sources.debian.org/patches/vtk9/9.1.0%2Breally9.1.0%2Bdfsg2-7.1/
if [[ ${major} -eq 9 && ${minor} -eq 2 ]]; then  # VTK == 9.2.x
    cd ${script_dir}/patches

    wget https://sources.debian.org/data/main/v/vtk9/9.1.0%2Breally9.1.0%2Bdfsg2-7.1/debian/patches/gcc-13.patch
    echo "0f7cb1212efe58cf87d4b0b46afbdd02a83643721e0abb4e280679d2c392f51b  gcc-13.patch" | sha256sum -c

    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/gcc-13.patch
fi

# Build and install
install_dir=${base_dir}/opt/vtk/${version}
mkdir -p ${install_dir}

mkdir -p ${src_dir}-build
cd ${src_dir}-build
cmake \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=OFF \
    -DBUILD_DOCUMENTATION=OFF \
    -DVTK_INSTALL_NO_DOCUMENTATION=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${install_dir} \
    -DCMAKE_INSTALL_RPATH=${install_dir}/lib/vtk-${major}.${minor} \
    ${src_dir} && \
make -j ${parallel} && \
make install

# Add modulefile
mkdir -p ${base_dir}/modulefiles/vtk
cd  ${base_dir}/modulefiles/vtk
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## vtk ${version} modulefile
##
proc ModulesTest { } {
    set paths "[getenv VTK_ROOT]
               [getenv VTK_ROOT]/include/vtk-${major}.${minor}
               [getenv VTK_ROOT]/lib"

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

setenv          VTK_ROOT             ${install_dir}

prepend-path    LIBRARY_PATH         ${install_dir}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/lib
prepend-path    LD_RUN_PATH          ${install_dir}/lib

prepend-path    INCLUDE              ${install_dir}/include/vtk-${major}.${minor}
prepend-path    C_INCLUDE_PATH       ${install_dir}/include/vtk-${major}.${minor}
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/include/vtk-${major}.${minor}

prepend-path    CMAKE_PREFIX_PATH    ${install_dir}

conflict vtk
EOF
