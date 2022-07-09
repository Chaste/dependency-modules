#!/bin/bash
# set -o errexit
# set -o nounset

MODULE_BOOST_VERSIONS='1.58.0 1.69.0'
MODULE_XERCES_VERSIONS='3.1.1 3.2.1'
MODULE_XSD_VERSIONS='3.3.0 4.0.0'
MODULE_VTK_VERSIONS='6.3.0 8.1.0'
MODULE_PETSC_VERSIONS='3.6.4 3.7.7 3.8.4 3.9.4 3.10.5 3.11.3 3.12.4'
MODULE_PETSC_ARCHS='linux-gnu linux-gnu-opt'

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

./install_cmake.sh --version=3.9.1 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

module switch cmake/3.9.1

./install_sundials.sh --version=2.7.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_sundials.sh --version=3.1.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_sundials.sh --version=4.1.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}
./install_sundials.sh --version=5.0.0 --modules-dir=${MODULES_DIR} --parallel=${NPROC}

#==================== BOOST ====================
read -r -d '' MODULE_BOOST_TEMPLATE <<'EOF'
#%Module1.0#####################################################################
###
## boost __VERSION__ modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for boost __VERSION__\n"
}

module-whatis "This adds the environment variables for boost __VERSION__"

setenv          BOOST_ROOT           __INSTALL_DIR__
prepend-path    CMAKE_PREFIX_PATH    __INSTALL_DIR__
prepend-path    LIBRARY_PATH         __INSTALL_DIR__/lib
prepend-path    LD_LIBRARY_PATH      __INSTALL_DIR__/lib
prepend-path    INCLUDE              __INSTALL_DIR__/include
prepend-path    C_INCLUDE_PATH       __INSTALL_DIR__/include
prepend-path    CPLUS_INCLUDE_PATH   __INSTALL_DIR__/include

conflict boost
EOF

mkdir ${MODULE_SOURCE_DIR}/boost
mkdir ${MODULE_INSTALL_DIR}/boost
mkdir ${MODULE_FILES_DIR}/boost

for version in ${MODULE_BOOST_VERSIONS}; do
    install_dir=${MODULE_INSTALL_DIR}/boost/${version}
    mkdir ${install_dir}

    ver_si_on=${version//\./_}  # convert 1.69.0 to 1_69_0
    version_arr=(${version//\./ })
    major=${version_arr[0]}
    minor=${version_arr[1]}

    cd  ${MODULE_SOURCE_DIR}/boost
    if [[ (${major} -lt 1) || ((${major} -eq 1) && (${minor} -le 70)) ]]; then
        wget https://downloads.sourceforge.net/project/boost/boost/${version}/boost_${ver_si_on}.tar.bz2
    else
        wget https://dl.bintray.com/boostorg/release/${version}/source/boost_${ver_si_on}.tar.bz2
    fi
    tar -xjf boost_${ver_si_on}.tar.bz2

    cd boost_${ver_si_on}
    if [[ (${major} -lt 1) || ((${major} -eq 1) && (${minor} -le 39)) ]]; then
        ./configure --prefix=${install_dir} && \
        make -j ${NPROC} && \
        make install
    elif [ ${major} -eq 1 ] && [ ${minor} -le 49 ]; then
        ./bootstrap.sh --prefix=${install_dir} && \
        ./bjam -j ${NPROC} install
    else
        ./bootstrap.sh --prefix=${install_dir} && \
        ./b2 -j ${NPROC} install
    fi

    if [ ${version} = 1.64.0 ]; then
        # Fix: https://github.com/boostorg/serialization/commit/1d86261581230e2dc5d617a9b16287d326f3e229
        sed -i.bak '25i\#include <boost/serialization/array_wrapper.hpp>' ${install_dir}/include/boost/serialization/array.hpp
    fi

    cd  ${MODULE_FILES_DIR}/boost
    echo "${MODULE_BOOST_TEMPLATE}" > ${version}
    sed -i "s|__VERSION__|${version}|g" ${version}
    sed -i "s|__INSTALL_DIR__|${install_dir}|g" ${version}
done

#==================== XERCES-C ====================
read -r -d '' MODULE_XERCES_TEMPLATE <<'EOF'
#%Module1.0#####################################################################
###
## xercesc __VERSION__ modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for xercesc __VERSION__\n"
}

module-whatis "This adds the environment variables for xercesc __VERSION__"

prepend-path    CMAKE_PREFIX_PATH    __INSTALL_DIR__
prepend-path    PATH                 __INSTALL_DIR__/bin
prepend-path    LIBRARY_PATH         __INSTALL_DIR__/lib
prepend-path    LD_LIBRARY_PATH      __INSTALL_DIR__/lib
prepend-path    INCLUDE              __INSTALL_DIR__/include
prepend-path    C_INCLUDE_PATH       __INSTALL_DIR__/include
prepend-path    CPLUS_INCLUDE_PATH   __INSTALL_DIR__/include

conflict xercesc
EOF

mkdir ${MODULE_SOURCE_DIR}/xercesc
mkdir ${MODULE_INSTALL_DIR}/xercesc
mkdir ${MODULE_FILES_DIR}/xercesc

for version in ${MODULE_XERCES_VERSIONS}; do
    install_dir=${MODULE_INSTALL_DIR}/xercesc/${version}
    mkdir ${install_dir}

    ver_si_on=${version//\./_}  # convert 3.1.1 to 3_1_1
    version_arr=(${version//\./ })
    major=${version_arr[0]}

    cd  ${MODULE_SOURCE_DIR}/xercesc
    if [ ${major} -le 2 ]; then
        wget https://archive.apache.org/dist/xerces/c/${major}/sources/xerces-c-src_${ver_si_on}.tar.gz
        tar -xzf xerces-c-src_${ver_si_on}.tar.gz
        cd xerces-c-src_${ver_si_on}
        export XERCESCROOT=$(pwd)
        cd src/xercesc
        ./runConfigure -plinux -cgcc -xg++ -P${install_dir} && \
        make -j ${NPROC} && \
        make install
    else
        wget https://archive.apache.org/dist/xerces/c/${major}/sources/xerces-c-${version}.tar.gz
        tar -xzf xerces-c-${version}.tar.gz
        cd xerces-c-${version}
        ./configure --enable-netaccessor-socket --prefix=${install_dir} && \
        make -j ${NPROC} && \
        make install
    fi

    cd  ${MODULE_FILES_DIR}/xercesc
    echo "${MODULE_XERCES_TEMPLATE}" > ${version}
    sed -i "s|__VERSION__|${version}|g" ${version}
    sed -i "s|__INSTALL_DIR__|${install_dir}|g" ${version}
done

#==================== XSD ====================
read -r -d '' MODULE_XSD_TEMPLATE <<'EOF'
#%Module1.0#####################################################################
###
## xsd __VERSION__ modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for xsd __VERSION__\n"
}

module-whatis "This adds the environment variables for xsd __VERSION__"

setenv          XSD_ROOT             __INSTALL_DIR__
prepend-path    CMAKE_PREFIX_PATH    __INSTALL_DIR__
prepend-path    PATH                 __INSTALL_DIR__/bin
prepend-path    LIBRARY_PATH         __INSTALL_DIR__/libxsd
prepend-path    LD_LIBRARY_PATH      __INSTALL_DIR__/libxsd

conflict xsd
EOF

mkdir ${MODULE_SOURCE_DIR}/xsd
mkdir ${MODULE_INSTALL_DIR}/xsd
mkdir ${MODULE_FILES_DIR}/xsd

cd  ${MODULE_SOURCE_DIR}/xsd
wget https://chaste.cs.ox.ac.uk/public/deps/xsd-setg.patch

for version in ${MODULE_XSD_VERSIONS}; do
    install_dir=${MODULE_INSTALL_DIR}/xsd/${version}
    mkdir ${install_dir}

    version_arr=(${version//\./ })
    major=${version_arr[0]}
    minor=${version_arr[1]}

    cd  ${MODULE_SOURCE_DIR}/xsd
    wget https://www.codesynthesis.com/download/xsd/${major}.${minor}/linux-gnu/x86_64/xsd-${version}-x86_64-linux-gnu.tar.bz2
    tar -xjf xsd-${version}-x86_64-linux-gnu.tar.bz2 -C ${install_dir} --strip-components=1

    if [ ${major} -eq 3 ]; then
        cd ${install_dir}
        patch -p0 <${MODULE_SOURCE_DIR}/xsd/xsd-setg.patch
    fi

    cd  ${MODULE_FILES_DIR}/xsd
    echo "${MODULE_XSD_TEMPLATE}" > ${version}
    sed -i "s|__VERSION__|${version}|g" ${version}
    sed -i "s|__INSTALL_DIR__|${install_dir}|g" ${version}
done

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

#==================== PETSC + HDF5 ====================
read -r -d '' MODULE_PETSC_TEMPLATE <<'EOF'
#%Module1.0#####################################################################
###
## petsc __VERSION__/__ARCH__ modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for petsc __VERSION__/__ARCH__\n"
}

module-whatis "This adds the environment variables for petsc __VERSION__/__ARCH__"

setenv          PETSC_ARCH           __ARCH__
setenv          PETSC_DIR            __INSTALL_DIR__
prepend-path    CMAKE_PREFIX_PATH    __INSTALL_DIR__/__ARCH__
prepend-path    PATH                 __INSTALL_DIR__/__ARCH__/bin
prepend-path    LIBRARY_PATH         __INSTALL_DIR__/__ARCH__/lib
prepend-path    LD_LIBRARY_PATH      __INSTALL_DIR__/__ARCH__/lib
prepend-path    INCLUDE              __INSTALL_DIR__/__ARCH__/include
prepend-path    C_INCLUDE_PATH       __INSTALL_DIR__/__ARCH__/include
prepend-path    CPLUS_INCLUDE_PATH   __INSTALL_DIR__/__ARCH__/include

conflict petsc
EOF

# Preferred HDF5 versions to bundle with PETSc
URL_HDF5_8_16=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.16/src/hdf5-1.8.16.tar.gz
URL_HDF5_8_21=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.21/src/hdf5-1.8.21.tar.gz
URL_HDF5_10_0=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.0-patch1/src/hdf5-1.10.0-patch1.tar.gz
URL_HDF5_10_1=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.1/src/hdf5-1.10.1.tar.gz
URL_HDF5_10_2=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.2/src/hdf5-1.10.2.tar.gz
URL_HDF5_10_3=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.3/src/hdf5-1.10.3.tar.gz
URL_HDF5_10_4=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.4/src/hdf5-1.10.4.tar.gz
URL_HDF5_10_5=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.5/src/hdf5-1.10.5.tar.gz

# Preferred MPICH versions
URL_MPICH_3_3=https://www.mpich.org/static/downloads/3.3/mpich-3.3.tar.gz
URL_MPICH_3_4=https://www.mpich.org/static/downloads/3.4a3/mpich-3.4a3.tar.gz

# Fixes for broken Hypre links in some PETSc versions
URL_HYPRE_2_11=https://github.com/hypre-space/hypre/archive/refs/tags/v2.11.1.tar.gz
URL_HYPRE_2_12=https://github.com/hypre-space/hypre/archive/refs/tags/v2.12.0.tar.gz
URL_HYPRE_2_14=https://github.com/hypre-space/hypre/archive/refs/tags/v2.14.0.tar.gz
URL_HYPRE_2_15=https://github.com/hypre-space/hypre/archive/refs/tags/v2.15.1.tar.gz

mkdir ${MODULE_SOURCE_DIR}/petsc
mkdir ${MODULE_INSTALL_DIR}/petsc
mkdir ${MODULE_FILES_DIR}/petsc

for version in ${MODULE_PETSC_VERSIONS}; do
    install_dir=${MODULE_INSTALL_DIR}/petsc/${version}
    mkdir ${install_dir}
    mkdir  ${MODULE_FILES_DIR}/petsc/${version}

    version_arr=(${version//\./ })
    major=${version_arr[0]}
    minor=${version_arr[1]}

    cd  ${MODULE_SOURCE_DIR}/petsc
    wget -nc https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-${version}.tar.gz
    tar -xzf petsc-lite-${version}.tar.gz -C ${install_dir} --strip-components=1

    mpich=1
    hdf5=1
    hypre=1

    # Retrieving packages to fix "url is not a tarball" errors
    if [[ (${major} -eq 3) && (${minor} -eq 6) ]]; then  # PETSc 3.6.x
        wget -nc ${URL_MPICH_3_3}
        wget -nc ${URL_HDF5_8_16}

        mpich=$(pwd)/$(basename ${URL_MPICH_3_3})
        hdf5=$(pwd)/$(basename ${URL_HDF5_8_16})

        module switch python/2.7.18  # configure needs Python 2 in this version

    elif [[ (${major} -eq 3) && (${minor} -eq 7) ]]; then  # PETSc 3.7.x
        wget -nc ${URL_MPICH_3_3}
        wget -nc ${URL_HDF5_10_0}
        wget -nc ${URL_HYPRE_2_11}  # Fixes broken hypre link in this version

        mpich=$(pwd)/$(basename ${URL_MPICH_3_3})
        hdf5=$(pwd)/$(basename ${URL_HDF5_10_0})
        hypre=$(pwd)/$(basename ${URL_HYPRE_2_11})

        module switch python/2.7.18  # configure needs Python 2 in this version

    elif [[ (${major} -eq 3) && (${minor} -eq 8) ]]; then  # PETSc 3.8.x
        wget -nc ${URL_MPICH_3_3}
        wget -nc ${URL_HDF5_8_21}
        wget -nc ${URL_HYPRE_2_12}  # Fixes broken hypre link in this version

        mpich=$(pwd)/$(basename ${URL_MPICH_3_3})
        hdf5=$(pwd)/$(basename ${URL_HDF5_8_21})
        hypre=$(pwd)/$(basename ${URL_HYPRE_2_12})

        module switch python/2.7.18  # configure needs Python 2 in this version

    elif [[ (${major} -eq 3) && (${minor} -eq 9) ]]; then  # PETSc 3.9.x
        wget -nc ${URL_MPICH_3_3}
        wget -nc ${URL_HDF5_10_3}
        wget -nc ${URL_HYPRE_2_14}  # Fixes broken hypre link in this version

        mpich=$(pwd)/$(basename ${URL_MPICH_3_3})
        hdf5=$(pwd)/$(basename ${URL_HDF5_10_3})
        hypre=$(pwd)/$(basename ${URL_HYPRE_2_14})

        module switch python/2.7.18  # configure needs Python 2 in this version

    elif [[ (${major} -eq 3) && (${minor} -eq 10) ]]; then  # PETSc 3.10.x
        wget -nc ${URL_MPICH_3_3}
        wget -nc ${URL_HDF5_10_4}
        wget -nc ${URL_HYPRE_2_14}  # Fixes broken hypre link in this version

        mpich=$(pwd)/$(basename ${URL_MPICH_3_3})
        hdf5=$(pwd)/$(basename ${URL_HDF5_10_4})
        hypre=$(pwd)/$(basename ${URL_HYPRE_2_14})

        module switch python/2.7.18  # configure needs Python 2 in this version

    elif [[ (${major} -eq 3) && (${minor} -eq 11) ]]; then  # PETSc 3.11.x
        wget -nc ${URL_MPICH_3_3}
        wget -nc ${URL_HDF5_10_5}
        wget -nc ${URL_HYPRE_2_15}  # Fixes broken hypre link in this version

        mpich=$(pwd)/$(basename ${URL_MPICH_3_3})
        hdf5=$(pwd)/$(basename ${URL_HDF5_10_5})
        hypre=$(pwd)/$(basename ${URL_HYPRE_2_15})

    elif [[ (${major} -eq 3) && (${minor} -eq 12) ]]; then  # PETSc 3.12.x
        wget -nc ${URL_MPICH_3_4}
        wget -nc ${URL_HDF5_10_4}

        mpich=$(pwd)/$(basename ${URL_MPICH_3_4})
        hdf5=$(pwd)/$(basename ${URL_HDF5_10_4})
    fi

    for arch in ${MODULE_PETSC_ARCHS}; do
        cd ${install_dir}
        export PETSC_DIR=$(pwd)

        case ${arch} in

            linux-gnu)
                export PETSC_ARCH=linux-gnu
                ./configure \
                    --with-make-np=${NPROC} \
                    --with-cc=gcc \
                    --with-cxx=g++ \
                    --with-fc=0 \
                    --COPTFLAGS=-Og \
                    --CXXOPTFLAGS=-Og \
                    --with-x=false \
                    --with-ssl=false \
                    --download-f2cblaslapack=1 \
                    --download-mpich=${mpich} \
                    --download-hdf5=${hdf5} \
                    --download-parmetis=1 \
                    --download-metis=1 \
                    --download-hypre=${hypre} \
                    --with-shared-libraries && \
                make all test
                ;;

            linux-gnu-opt)
                export PETSC_ARCH=linux-gnu-opt
                ./configure \
                    --with-make-np=${NPROC} \
                    --with-cc=gcc \
                    --with-cxx=g++ \
                    --with-fc=0 \
                    --COPTFLAGS=-Og \
                    --CXXOPTFLAGS=-Og \
                    --with-x=false \
                    --with-ssl=false \
                    --download-f2cblaslapack=1 \
                    --download-mpich=${mpich} \
                    --download-hdf5=${hdf5} \
                    --download-parmetis=1 \
                    --download-metis=1 \
                    --download-hypre=${hypre} \
                    --with-shared-libraries \
                    --with-debugging=0 && \
                make all test
                ;;
            *)
                #TODO Catch unknown arch error
                ;;
        esac

        cd ${MODULE_FILES_DIR}/petsc/${version}
        echo "${MODULE_PETSC_TEMPLATE}" > ${arch}
        sed -i "s|__VERSION__|${version}|g" ${arch}
        sed -i "s|__ARCH__|${arch}|g" ${arch}
        sed -i "s|__INSTALL_DIR__|${install_dir}|g" ${arch}
    done
    module unload python/2.7.18
done
