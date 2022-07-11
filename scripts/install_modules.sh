#!/bin/bash
# set -o errexit
# set -o nounset

MODULE_VTK_VERSIONS='6.3.0 8.1.0'

MODULES_DIR=~/modules
MODULE_SOURCE_DIR=${MODULES_DIR}/src
MODULE_INSTALL_DIR=${MODULES_DIR}/opt
MODULE_FILES_DIR=${MODULES_DIR}/modulefiles

NPROC=$(( $(nproc) < 8 ? $(nproc) : 8 ))

mkdir -p ${MODULE_SOURCE_DIR}
mkdir -p ${MODULE_INSTALL_DIR}
mkdir -p ${MODULE_FILES_DIR}

echo "module use ${MODULE_FILES_DIR}" >> ~/.bashrc
source ~/.bashrc

./install_python.sh --version=2.7.18 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_python.sh --version=3.8.12 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

module switch python/3.8.12

./install_cmake.sh --version=3.9.1 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

module switch cmake/3.9.1

./install_xsd.sh --version=3.3.0 --modules-dir=${MODULES_DIR}
./install_xsd.sh --version=4.0.0 --modules-dir=${MODULES_DIR}

./install_xercesc.sh --version=3.1.1 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_xercesc.sh --version=3.1.2 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_xercesc.sh --version=3.1.3 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_xercesc.sh --version=3.1.4 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_xercesc.sh --version=3.2.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_xercesc.sh --version=3.2.1 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

./install_sundials.sh --version=2.7.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_sundials.sh --version=3.1.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_sundials.sh --version=4.1.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_sundials.sh --version=5.0.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

./install_boost.sh --version=1.58.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_boost.sh --version=1.60.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_boost.sh --version=1.61.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_boost.sh --version=1.62.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_boost.sh --version=1.66.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_boost.sh --version=1.67.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_boost.sh --version=1.69.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

module switch python/2.7.18  # For PETSc versions < 3.11.x configuration needs Python 2

# PETSc 3.6.4 + HDF5 1.8.16 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.6.4 \
    --hdf5-version=1.8.16 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.6.4 \
    --hdf5-version=1.8.16 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

# PETSc 3.7.7 + HDF5 1.10.0-patch1 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.7.7 \
    --hdf5-version=1.10.0-patch1 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.7.7 \
    --hdf5-version=1.10.0-patch1 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

# PETSc 3.8.4 + HDF5 1.8.21 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.8.4 \
    --hdf5-version=1.8.21 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.8.4 \
    --hdf5-version=1.8.21 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

# PETSc 3.9.4 + HDF5 1.10.3 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.9.4 \
    --hdf5-version=1.10.3 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.9.4 \
    --hdf5-version=1.10.3 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

# PETSc 3.10.5 + HDF5 1.10.4 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.10.5 \
    --hdf5-version=1.10.4 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.10.5 \
    --hdf5-version=1.10.4 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

module switch python/3.8.12  # For PETSc versions >= 3.11.x configuration supports Python 3

# PETSc 3.11.3 + HDF5 1.10.5 + MPICH 3.3
./install_petsc_hdf5.sh \
    --petsc-version=3.11.3 \
    --hdf5-version=1.10.5 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.11.3 \
    --hdf5-version=1.10.5 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

# PETSc 3.12.4 + HDF5 1.10.4 + MPICH 3.4a3
./install_petsc_hdf5.sh \
    --petsc-version=3.12.4 \
    --hdf5-version=1.10.4 \
    --petsc-arch=linux-gnu \
    --mpich-version=3.4a3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

./install_petsc_hdf5.sh \
    --petsc-version=3.12.4 \
    --hdf5-version=1.10.4 \
    --petsc-arch=linux-gnu-opt \
    --mpich-version=3.4a3 \
    --modules-dir=${MODULES_DIR} \
    --parallel=${NPROC}

#==================== VTK ====================
read -r -d '' MODULE_VTK_TEMPLATE <<'EOF'
#%Module1.0#####################################################################
###
## vtk __VERSION__ modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for vtk __VERSION__\n"
}

module-whatis "This adds the environment variables for vtk __VERSION__"

setenv          VTK_ROOT             __INSTALL_DIR__
prepend-path    CMAKE_PREFIX_PATH    __INSTALL_DIR__
prepend-path    PATH                 __INSTALL_DIR__/bin
prepend-path    LIBRARY_PATH         __INSTALL_DIR__/lib
prepend-path    LD_LIBRARY_PATH      __INSTALL_DIR__/lib
prepend-path    INCLUDE              __INSTALL_DIR__/include/vtk-__MAJOR__.__MINOR__
prepend-path    C_INCLUDE_PATH       __INSTALL_DIR__/include/vtk-__MAJOR__.__MINOR__
prepend-path    CPLUS_INCLUDE_PATH   __INSTALL_DIR__/include/vtk-__MAJOR__.__MINOR__

conflict vtk
EOF

mkdir ${MODULE_SOURCE_DIR}/vtk
mkdir ${MODULE_INSTALL_DIR}/vtk
mkdir ${MODULE_FILES_DIR}/vtk

for version in ${MODULE_VTK_VERSIONS}; do
    install_dir=${MODULE_INSTALL_DIR}/vtk/${version}
    mkdir ${install_dir}

    version_arr=(${version//\./ })
    major=${version_arr[0]}
    minor=${version_arr[1]}

    cd  ${MODULE_SOURCE_DIR}/vtk
    src_dir=VTK-${version}
    mkdir ${src_dir}
    if [[ (${major} -lt 6) || ((${major} -eq 6) && (${minor} -le 0)) ]]; then
        wget http://www.vtk.org/files/release/${major}.${minor}/vtk-${version}.tar.gz
        tar -xzf vtk-${version}.tar.gz -C ${src_dir} --strip-components=1
    else
        wget https://github.com/Kitware/VTK/archive/v${version}.tar.gz
        tar -xzf v${version}.tar.gz -C ${src_dir} --strip-components=1
    fi

    if [ ${version} = 6.3.0 ]; then
        # Fix for recognizing gcc 6-9: https://public.kitware.com/pipermail/vtkusers/2017-April/098448.html
        cp ./${src_dir}/CMake/vtkCompilerExtras.cmake ./${src_dir}/CMake/vtkCompilerExtras.cmake.bak
        sed -i '35s/^/#/' ./${src_dir}/CMake/vtkCompilerExtras.cmake
        sed -i '36i\string (REGEX MATCH "[3-9]\\\\.[0-9]\\\\.[0-9]*"' ./${src_dir}/CMake/vtkCompilerExtras.cmake

        cp ./${src_dir}/CMake/GenerateExportHeader.cmake ./${src_dir}/CMake/GenerateExportHeader.cmake.bak
        sed -i '169s/^/#/' ./${src_dir}/CMake/GenerateExportHeader.cmake
        sed -i '170i\   string (REGEX MATCH "[3-9]\\\\.[0-9]\\\\.[0-9]*"' ./${src_dir}/CMake/GenerateExportHeader.cmake
    fi

    build_dir=${src_dir}-build
    mkdir ${build_dir}
    cd ${build_dir}
    cmake -DBUILD_SHARED_LIBS=ON \
            -DCMAKE_INSTALL_PREFIX=${install_dir} \
            -DCMAKE_INSTALL_RPATH=${install_dir}/lib/vtk-${major}.${minor} ../${src_dir} && \
    make -j ${NPROC} && \
    make install

    cd  ${MODULE_FILES_DIR}/vtk
    echo "${MODULE_VTK_TEMPLATE}" > ${version}
    sed -i "s|__VERSION__|${version}|g" ${version}
    sed -i "s|__INSTALL_DIR__|${install_dir}|g" ${version}
    sed -i "s|__MAJOR__|${major}|g" ${version}
    sed -i "s|__MINOR__|${minor}|g" ${version}
done
