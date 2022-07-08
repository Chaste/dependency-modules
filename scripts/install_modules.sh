#!/bin/bash
# set -o errexit
# set -o nounset

MODULE_PYTHON_VERSIONS='2.7.18'
MODULE_CMAKE_VERSIONS='3.9.1'

MODULE_SUNDIALS_VERSIONS='2.7.0 4.1.0'
MODULE_BOOST_VERSIONS='1.58.0 1.69.0'
MODULE_XERCES_VERSIONS='3.1.1 3.2.1'
MODULE_XSD_VERSIONS='3.3.0 4.0.0'
MODULE_VTK_VERSIONS='6.3.0 8.1.0'
MODULE_PETSC_VERSIONS='3.9.2 3.12.5'
MODULE_PETSC_ARCHS='linux-gnu linux-gnu-opt linux-gnu-profile'

MODULE_DIR=~/modules
MODULE_SOURCE_DIR=${MODULE_DIR}/src
MODULE_INSTALL_DIR=${MODULE_DIR}/opt
MODULE_FILES_DIR=${MODULE_DIR}/modulefiles

NPROC=$(( $(nproc) < 8 ? $(nproc) : 8 ))

mkdir -p ${MODULE_SOURCE_DIR}
mkdir -p ${MODULE_INSTALL_DIR}
mkdir -p ${MODULE_FILES_DIR}

echo "module use ${MODULE_FILES_DIR}" >> ~/.bashrc
source ~/.bashrc

#==================== PYTHON ====================
read -r -d '' MODULE_PYTHON_TEMPLATE <<'EOF'
#%Module1.0#####################################################################
###
## python __VERSION__ modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for python __VERSION__\n"
}

module-whatis "This adds the environment variables for python __VERSION__"

prepend-path    PATH    __INSTALL_DIR__/bin

conflict python
EOF

mkdir ${MODULE_SOURCE_DIR}/python
mkdir ${MODULE_INSTALL_DIR}/python
mkdir ${MODULE_FILES_DIR}/python

for version in ${MODULE_PYTHON_VERSIONS}; do
    install_dir=${MODULE_INSTALL_DIR}/python/${version}
    mkdir ${install_dir}

    version_arr=(${version//\./ })
    major=${version_arr[0]}
    minor=${version_arr[1]}

    cd  ${MODULE_SOURCE_DIR}/python
    wget https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz
    tar -xf Python-${version}.tar.xz

    cd Python-${version}
    ./configure --prefix=${install_dir} && \
    make -j ${NPROC} && \
    make install

    cd  ${MODULE_FILES_DIR}/python
    echo "${MODULE_PYTHON_TEMPLATE}" > ${version}
    sed -i "s|__VERSION__|${version}|g" ${version}
    sed -i "s|__INSTALL_DIR__|${install_dir}|g" ${version}
done

#==================== CMAKE ====================
read -r -d '' MODULE_CMAKE_TEMPLATE <<'EOF'
#%Module1.0#####################################################################
###
## cmake __VERSION__ modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for cmake __VERSION__\n"
}

module-whatis "This adds the environment variables for cmake __VERSION__"

prepend-path    PATH    __INSTALL_DIR__/bin

conflict cmake
EOF

mkdir ${MODULE_SOURCE_DIR}/cmake
mkdir ${MODULE_INSTALL_DIR}/cmake
mkdir ${MODULE_FILES_DIR}/cmake

for version in ${MODULE_CMAKE_VERSIONS}; do
    install_dir=${MODULE_INSTALL_DIR}/cmake/${version}
    mkdir ${install_dir}

    version_arr=(${version//\./ })
    major=${version_arr[0]}
    minor=${version_arr[1]}

    cd  ${MODULE_SOURCE_DIR}/cmake
    wget https://cmake.org/files/v${major}.${minor}/cmake-${version}.tar.gz
    tar -xzf cmake-${version}.tar.gz

    cd cmake-${version}
    ./bootstrap --prefix=${install_dir} --parallel=${NPROC} && \
    make -j ${NPROC} && \
    make install

    cd  ${MODULE_FILES_DIR}/cmake
    echo "${MODULE_CMAKE_TEMPLATE}" > ${version}
    sed -i "s|__VERSION__|${version}|g" ${version}
    sed -i "s|__INSTALL_DIR__|${install_dir}|g" ${version}
done

module switch cmake/3.9.1

#==================== SUNDIALS ====================
read -r -d '' MODULE_SUNDIALS_TEMPLATE <<'EOF'
#%Module1.0#####################################################################
###
## sundials __VERSION__ modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for sundials __VERSION__\n"
}

module-whatis "This adds the environment variables for sundials __VERSION__"

setenv          SUNDIALS_ROOT        __INSTALL_DIR__
prepend-path    CMAKE_PREFIX_PATH    __INSTALL_DIR__
prepend-path    LIBRARY_PATH         __INSTALL_DIR__/lib
prepend-path    LD_LIBRARY_PATH      __INSTALL_DIR__/lib
prepend-path    INCLUDE              __INSTALL_DIR__/include
prepend-path    C_INCLUDE_PATH       __INSTALL_DIR__/include
prepend-path    CPLUS_INCLUDE_PATH   __INSTALL_DIR__/include

conflict sundials
EOF

mkdir ${MODULE_SOURCE_DIR}/sundials
mkdir ${MODULE_INSTALL_DIR}/sundials
mkdir ${MODULE_FILES_DIR}/sundials

for version in ${MODULE_SUNDIALS_VERSIONS}; do
    install_dir=${MODULE_INSTALL_DIR}/sundials/${version}
    mkdir ${install_dir}

    cd  ${MODULE_SOURCE_DIR}/sundials
    wget https://github.com/LLNL/sundials/releases/download/v${version}/sundials-${version}.tar.gz
    tar -xzf sundials-${version}.tar.gz

    cd sundials-${version}
    mkdir build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=${install_dir} \
            -DBUILD_SHARED_LIBS=ON \
            -DCMAKE_BUILD_TYPE=Release \
            -DEXAMPLES_ENABLE=OFF .. && \
    make -j ${NPROC} && \
    make install

    cd  ${MODULE_FILES_DIR}/sundials
    echo "${MODULE_SUNDIALS_TEMPLATE}" > ${version}
    sed -i "s|__VERSION__|${version}|g" ${version}
    sed -i "s|__INSTALL_DIR__|${install_dir}|g" ${version}
done

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
        #Fix for recognizing gcc 6-9: https://public.kitware.com/pipermail/vtkusers/2017-April/098448.html
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

#==================== PETSC ====================
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
    wget https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-${version}.tar.gz
    tar -xzf petsc-lite-${version}.tar.gz -C ${install_dir} --strip-components=1

    if [[ (${major} -lt 3) || ((${major} -eq 3) && (${minor} -le 9)) ]]; then
        module switch python/2.7.18
    fi

    for arch in ${MODULE_PETSC_ARCHS}; do
        cd ${install_dir}
        export PETSC_DIR=$(pwd)

        case ${arch} in

            linux-gnu)
                export PETSC_ARCH=linux-gnu
                ./configure --with-make-np=${NPROC} \
                            --download-f2cblaslapack=1 \
                            --download-mpich=1 \
                            --download-hdf5=1 \
                            --download-parmetis=1 \
                            --download-metis=1 \
                            --download-hypre=1 \
                            --with-x=false \
                            --with-shared-libraries && \
                make all
                ;;

            linux-gnu-opt)
                export PETSC_ARCH=linux-gnu-opt
                ./configure --with-make-np=${NPROC} \
                            --download-f2cblaslapack=1 \
                            --download-mpich=1 \
                            --download-hdf5=1 \
                            --download-parmetis=1 \
                            --download-metis=1 \
                            --download-hypre=1 \
                            --with-x=false \
                            --with-shared-libraries \
                            --with-debugging=0 && \
                make all
                ;;

            linux-gnu-profile)
                export PETSC_ARCH=linux-gnu-profile
                ./configure --with-make-np=${NPROC} \
                            --download-f2cblaslapack=1 \
                            --download-mpich=1 \
                            --download-hdf5=1 \
                            --download-parmetis=1 \
                            --download-metis=1 \
                            --download-hypre=1 \
                            --with-x=false \
                            --with-shared-libraries \
                            --CFLAGS="-fno-omit-frame-pointer -pg" \
                            --CXX_CXXFLAGS="-fno-omit-frame-pointer -pg" \
                            --LDFLAGS=-pg && \
                make all
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
