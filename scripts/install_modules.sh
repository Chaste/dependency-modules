#!/bin/bash
# set -o errexit
# set -o nounset

MODULE_CMAKE_VERSIONS='2.4.8 2.8.12.2 3.9.1'

MODULE_SUNDIALS_VERSIONS='2.7.0 4.1.0'
MODULE_BOOST_VERSIONS='1.58.0 1.69.0'
MODULE_XERCES_VERSIONS='3.1.1 3.2.1'
MODULE_XSD_VERSIONS='3.3.0 4.0.0'
MODULE_VTK_VERSIONS='8.1.0' # TODO: 5.10.1

MODULE_SOURCE_DIR=~/modules/src
MODULE_INSTALL_DIR=~/modules/opt
MODULE_FILES_DIR=~/modulefiles

NPROC=$(( $(nproc) < 8 ? $(nproc) : 8 ))

mkdir -p ${MODULE_SOURCE_DIR}
mkdir -p ${MODULE_INSTALL_DIR}
mkdir -p ${MODULE_FILES_DIR}

echo "module use ${MODULE_FILES_DIR}" >> ~/.bashrc
source ~/.bashrc

#==================== CMAKE ====================
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
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## cmake ${version} modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for cmake ${version}\n"
}

module-whatis "This adds the environment variables for cmake ${version}"

prepend-path    PATH    ${install_dir}/bin

conflict cmake
EOF
done

module switch cmake/3.9.1

#==================== SUNDIALS ====================
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
cmake -DCMAKE_INSTALL_PREFIX:PATH=${install_dir} \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DEXAMPLES_ENABLE=OFF .. && \
make -j ${NPROC} && \
make install

cd  ${MODULE_FILES_DIR}/sundials
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## sundials ${version} modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for sundials ${version}\n"
}

module-whatis "This adds the environment variables for sundials ${version}"

setenv          SUNDIALS_ROOT        ${install_dir}
prepend-path    CMAKE_PREFIX_PATH    ${install_dir}
prepend-path    LIBRARY_PATH         ${install_dir}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/lib
prepend-path    INCLUDE              ${install_dir}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/include

conflict sundials
EOF
done

#==================== BOOST ====================
mkdir ${MODULE_SOURCE_DIR}/boost
mkdir ${MODULE_INSTALL_DIR}/boost
mkdir ${MODULE_FILES_DIR}/boost

for version in ${MODULE_BOOST_VERSIONS}; do
install_dir=${MODULE_INSTALL_DIR}/boost/${version}
mkdir ${install_dir}

ver_si_on=${version//\./_}
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

cd  ${MODULE_FILES_DIR}/boost
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## boost ${version} modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for boost ${version}\n"
}

module-whatis "This adds the environment variables for boost ${version}"

setenv          BOOST_ROOT           ${install_dir}
prepend-path    CMAKE_PREFIX_PATH    ${install_dir}
prepend-path    LIBRARY_PATH         ${install_dir}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/lib
prepend-path    INCLUDE              ${install_dir}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/include

conflict boost
EOF
done

#==================== XERCES-C ====================
mkdir ${MODULE_SOURCE_DIR}/xercesc
mkdir ${MODULE_INSTALL_DIR}/xercesc
mkdir ${MODULE_FILES_DIR}/xercesc

for version in ${MODULE_XERCES_VERSIONS}; do
install_dir=${MODULE_INSTALL_DIR}/xercesc/${version}
mkdir ${install_dir}

ver_si_on=${version//\./_}
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
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## xercesc ${version} modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for xercesc ${version}\n"
}

module-whatis "This adds the environment variables for xercesc ${version}"

prepend-path    CMAKE_PREFIX_PATH    ${install_dir}
prepend-path    PATH                 ${install_dir}/bin
prepend-path    LIBRARY_PATH         ${install_dir}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/lib
prepend-path    INCLUDE              ${install_dir}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/include

conflict xercesc
EOF
done

#==================== XSD ====================
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
tar -xjf xsd-${version}-x86_64-linux-gnu.tar.bz2

rsync -a --delete xsd-${version}-x86_64-linux-gnu/ ${install_dir}/

if [ ${major} -eq 3 ]; then
    cd ${install_dir}
    patch -p0 <${MODULE_SOURCE_DIR}/xsd/xsd-setg.patch
fi

cd  ${MODULE_FILES_DIR}/xsd
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## xsd ${version} modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for xsd ${version}\n"
}

module-whatis "This adds the environment variables for xsd ${version}"

setenv          XSD_ROOT             ${install_dir}
prepend-path    CMAKE_PREFIX_PATH    ${install_dir}
prepend-path    PATH                 ${install_dir}/bin
prepend-path    LIBRARY_PATH         ${install_dir}/libxsd
prepend-path    LD_LIBRARY_PATH      ${install_dir}/libxsd

conflict xsd
EOF
done

#==================== VTK ====================
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

build_dir=build-${src_dir}
mkdir ${build_dir}
cd ${build_dir}
module switch cmake/2.6.3
cmake -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_INSTALL_PREFIX=${install_dir} \
        -DCMAKE_INSTALL_RPATH=${install_dir}/lib/vtk-${major}.${minor} ../${src_dir} && \
make -j $(nproc) && \
make install

cd  ${MODULE_FILES_DIR}/vtk
cat <<EOF > ${version}
#%Module1.0#####################################################################
###
## vtk ${version} modulefile
##
proc ModulesHelp { } {
    puts stderr "\tThis adds the environment variables for vtk ${version}\n"
}

module-whatis "This adds the environment variables for vtk ${version}"

setenv          VTK_ROOT             ${install_dir}
prepend-path    CMAKE_PREFIX_PATH    ${install_dir}
prepend-path    PATH                 ${install_dir}/bin
prepend-path    LIBRARY_PATH         ${install_dir}/lib
prepend-path    LD_LIBRARY_PATH      ${install_dir}/lib
prepend-path    INCLUDE              ${install_dir}/include
prepend-path    C_INCLUDE_PATH       ${install_dir}/include
prepend-path    CPLUS_INCLUDE_PATH   ${install_dir}/include

conflict vtk
EOF
done
