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

# Unsupported versions: https://chaste.cs.ox.ac.uk/trac/wiki/InstallGuides/DependencyVersions
if [[ (${major} -lt 6) || ((${major} -eq 6) && (${minor} -lt 3)) ]]; then  # VTK < 6.3.x
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

# Patch for Python 3.7+ in VTK 7.0.x to 8.1.x
if [[ ${major} -eq 7 || (${major} -eq 8 && ${minor} -le 1) ]]; then  # 7.0.x VTK <= 8.1.x
    wget -O py37_api_change.patch https://gitlab.kitware.com/vtk/vtk/commit/706f1b397df09a27ab8981ab9464547028d0c322.patch
    cd ${src_dir}
    patch -p1 < ../py37_api_change.patch
    cd ..
fi

# Tweak for detecting gcc 6-11: https://public.kitware.com/pipermail/vtkusers/2017-April/098448.html
if [[ ${major} -lt 7 || (${major} -eq 7 && ${minor} -eq 0) ]]; then  # VTK <= 7.0.x
    sed -i.bak 's/string (REGEX MATCH "\[345\]/string (REGEX MATCH "(\[3-9\]\|1\[0-1\])/g' ${src_dir}/CMake/vtkCompilerExtras.cmake
    sed -i.bak 's/string(REGEX MATCH "\[345\]/string(REGEX MATCH "(\[3-9\]\|1\[0-1\])/g' ${src_dir}/CMake/GenerateExportHeader.cmake
fi

# Build and install
install_dir=${base_dir}/opt/vtk/${version}
mkdir -p ${install_dir}

mkdir -p ${src_dir}-build
cd ${src_dir}-build
cmake \
    -DBUILD_SHARED_LIBS=ON \
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
