#!/bin/bash

# https://sources.debian.org/patches/vtk7/7.1.1%2Bdfsg2-10.2/

wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/10_allpatches.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/20_soversion-sharedlib.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/30_matplotlib.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/40_use_system_sqlite.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/60_use_system_mpi4py.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/70_fix_ftbfs_gcc49.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/80_fix_arm_compilation.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/100_javac-heap.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/101_java_install_path.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/105_unforce_embedded_glew.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/106_install_doxygen_scripts_in_nodoc_build.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/99-hdf5-1.10-compatibility
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/108_Doxygen-use-mathjax.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/109_java-jar-nonjavafiles.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/110_python-371.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/111_fix_perl.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/112_riscv_support.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/113_fix_python_equal.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/115_support-gcc10.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/mysq8_my_bool.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/3edc0de2b04ae1e100c229e592d6b9fa94f2915a.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/581d9eb874b2b80a3fb21c739a96fa6f955ffb5e.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/gcc-11.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/ffmpeg-5.patch

combinediff 10_allpatches.patch 20_soversion-sharedlib.patch > tmp1.patch
combinediff tmp1.patch 30_matplotlib.patch > tmp2.patch
combinediff tmp2.patch 40_use_system_sqlite.patch > tmp1.patch 
combinediff tmp1.patch 60_use_system_mpi4py.patch > tmp2.patch
combinediff tmp2.patch 70_fix_ftbfs_gcc49.patch > tmp1.patch
combinediff tmp1.patch 80_fix_arm_compilation.patch > tmp2.patch
combinediff tmp2.patch 100_javac-heap.patch > tmp1.patch 
combinediff tmp1.patch 101_java_install_path.patch > tmp2.patch 
combinediff tmp2.patch 105_unforce_embedded_glew.patch > tmp1.patch 
combinediff tmp1.patch 106_install_doxygen_scripts_in_nodoc_build.patch > tmp2.patch 
combinediff tmp2.patch 108_Doxygen-use-mathjax.patch > tmp1.patch 
combinediff tmp1.patch 109_java-jar-nonjavafiles.patch > tmp2.patch 
combinediff tmp2.patch 110_python-371.patch > tmp1.patch 
combinediff tmp1.patch 111_fix_perl.patch > tmp2.patch 
combinediff tmp2.patch 112_riscv_support.patch > tmp1.patch 
combinediff tmp1.patch 113_fix_python_equal.patch > tmp2.patch 
combinediff tmp2.patch 115_support-gcc10.patch > tmp1.patch 
combinediff tmp1.patch mysq8_my_bool.patch > tmp2.patch 
combinediff tmp2.patch 3edc0de2b04ae1e100c229e592d6b9fa94f2915a.patch > tmp1.patch 
combinediff tmp1.patch 581d9eb874b2b80a3fb21c739a96fa6f955ffb5e.patch > tmp2.patch 
combinediff tmp2.patch gcc-11.patch > tmp1.patch 
combinediff tmp1.patch ffmpeg-5.patch > vtk7.patch 

rm tmp1.patch tmp2.patch
