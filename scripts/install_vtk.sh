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

# Use Ubuntu system version
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

wget -nc https://github.com/Kitware/VTK/archive/v${version}.tar.gz
tar -xzf v${version}.tar.gz -C ${src_dir} --strip-components=1

# VTK 6.3.x patches: https://sources.debian.org/patches/vtk6/
if [[ ${major} -eq 6 && ${minor} -eq 3 ]]; then  # VTK == 6.3.x
    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/10_allpatches.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/20_soversion-sharedlib.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/30_matplotlib.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/60_use_system_mpi4py.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/70_fix_ftbfs_gcc49.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/90_gdal-2.0.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/95_ffmpeg_2.9.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/97_fix_latex_doxygen.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/99-hdf5-1.10-compatibility
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/100_javac-heap.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/101_java_install_path.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/105_unforce_embedded_glew.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/106_install_doxygen_scripts_in_nodoc_build.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/108_Doxygen-use-mathjax.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/109_infovis_boost.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/110_remove_nonfree_from_build.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/120_fix_ftbfs_qtpainter.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/3edc0de2b04ae1e100c229e592d6b9fa94f2915a.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/581d9eb874b2b80a3fb21c739a96fa6f955ffb5e.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/new-freetype.patch
    patch -t -p1 < ${script_dir}/patches/vtk/6.3/vtk6-gcc11-support.patch
fi

# VTK 7.1.x patches: https://sources.debian.org/patches/vtk7/
if [[ ${major} -eq 7 && ${minor} -eq 1 ]]; then  # VTK == 7.1.x
    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/10_allpatches.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/20_soversion-sharedlib.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/30_matplotlib.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/40_use_system_sqlite.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/60_use_system_mpi4py.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/70_fix_ftbfs_gcc49.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/80_fix_arm_compilation.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/99-hdf5-1.10-compatibility
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/100_javac-heap.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/101_java_install_path.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/105_unforce_embedded_glew.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/106_install_doxygen_scripts_in_nodoc_build.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/108_Doxygen-use-mathjax.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/109_java-jar-nonjavafiles.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/110_python-371.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/111_fix_perl.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/112_riscv_support.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/113_fix_python_equal.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/115_support-gcc10.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/mysq8_my_bool.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/3edc0de2b04ae1e100c229e592d6b9fa94f2915a.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/581d9eb874b2b80a3fb21c739a96fa6f955ffb5e.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/gcc-11.patch
    patch -t -p1 < ${script_dir}/patches/vtk/7.1/ffmpeg-5.patch
fi

# VTK 8.1.x patches
if [[ ${major} -eq 8 && ${minor} -eq 1 ]]; then  # VTK == 8.1.x
    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/20_soversion-sharedlib.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/30_matplotlib.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/60_use_system_mpi4py.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/70_vtk8_fix_ftbfs_gcc49.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/100_javac-heap.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/101_java_install_path.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/106_install_doxygen_scripts_in_nodoc_build.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/108_Doxygen-use-mathjax.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/109_java-jar-nonjavafiles.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/110_python-371.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/111_fix_perl.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/112_riscv_support.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/113_vtk8_fix_python_equal.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/115_support-gcc10.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/mysq8_my_bool.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/3edc0de2b04ae1e100c229e592d6b9fa94f2915a.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/581d9eb874b2b80a3fb21c739a96fa6f955ffb5e.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.1/vtk8-gcc-11-exodus.patch
fi

# VTK 8.2.x patches
if [[ ${major} -eq 8 && ${minor} -eq 2 ]]; then  # VTK == 8.2.x
    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/20_soversion-sharedlib.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/30_matplotlib.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/60_vtk8_use_system_mpi4py.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/70_vtk8_fix_ftbfs_gcc49.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/100_javac-heap.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/101_java_install_path.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/106_install_doxygen_scripts_in_nodoc_build.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/108_Doxygen-use-mathjax.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/109_java-jar-nonjavafiles.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/110_python-371.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/111_fix_perl.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/112_riscv_support.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/113_vtk8_fix_python_equal.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/115_support-gcc10.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/mysq8_my_bool.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/3edc0de2b04ae1e100c229e592d6b9fa94f2915a.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/581d9eb874b2b80a3fb21c739a96fa6f955ffb5e.patch
    patch -t -p1 < ${script_dir}/patches/vtk/8.2/vtk8-gcc-11-exodus.patch
fi

# VTK 9.0.x patches: https://sources.debian.org/patches/vtk9/
if [[ ${major} -eq 9 && ${minor} -eq 0 ]]; then  # VTK == 9.0.x
    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/vtk/9.0/50_fix_python-modules_path.patch
    patch -t -p1 < ${script_dir}/patches/vtk/9.0/70_fix_python_numpy_warning.patch
    patch -t -p1 < ${script_dir}/patches/vtk/9.0/fix-limits.patch
fi

# VTK 9.1.x patches: https://sources.debian.org/patches/vtk9/
if [[ ${major} -eq 9 && ${minor} -eq 1 ]]; then  # VTK == 9.1.x
    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/vtk/9.1/gcc-13.patch
fi

# VTK 9.2.x patches
if [[ ${major} -eq 9 && ${minor} -eq 2 ]]; then  # VTK == 9.2.x
    cd ${src_dir}
    patch -t -p1 < ${script_dir}/patches/vtk/9.2/gcc-13.patch
fi

# Build and install
install_dir=${base_dir}/opt/vtk/${version}
mkdir -p ${install_dir}

mkdir -p ${src_dir}-build
cd ${src_dir}-build
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${install_dir} \
    -DCMAKE_INSTALL_RPATH=${install_dir}/lib/vtk-${major}.${minor} \
    -DBUILD_SHARED_LIBS=ON \
    -DVTK_BUILD_EXAMPLES=OFF \
    -DVTK_BUILD_TESTING=OFF \
    -DVTK_BUILD_DOCUMENTATION=OFF \
    -DVTK_GROUP_ENABLE_MPI=YES \
    -DVTK_USE_MPI=YES \
    -DVTK_INSTALL_NO_DOCUMENTATION=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_doubleconversion=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_eigen=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_expat=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_fmt=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_freetype=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_gl2ps=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_glew=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_jpeg=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_jsoncpp=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_libproj=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_libxml2=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_lz4=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_lzma=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_netcdf=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_ogg=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_png=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_sqlite=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_theora=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_tiff=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_utf8=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_zlib=ON \
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
