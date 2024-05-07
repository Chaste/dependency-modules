#!/bin/bash

# https://sources.debian.org/patches/vtk7/7.1.1%2Bdfsg2-10.2/

wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/20_soversion-sharedlib.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/30_matplotlib.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/70_fix_ftbfs_gcc49.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/100_javac-heap.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/101_java_install_path.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/106_install_doxygen_scripts_in_nodoc_build.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/108_Doxygen-use-mathjax.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/109_java-jar-nonjavafiles.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/110_python-371.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/111_fix_perl.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/112_riscv_support.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/115_support-gcc10.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/mysq8_my_bool.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/3edc0de2b04ae1e100c229e592d6b9fa94f2915a.patch
wget -nc https://sources.debian.org/data/main/v/vtk7/7.1.1%2Bdfsg2-10.2/debian/patches/581d9eb874b2b80a3fb21c739a96fa6f955ffb5e.patch

combinediff 20_soversion-sharedlib.patch 30_matplotlib.patch > tmp1.patch
combinediff tmp1.patch vtk8-70_fix_ftbfs_gcc49.patch > tmp2.patch
combinediff tmp2.patch 100_javac-heap.patch > tmp1.patch 
combinediff tmp1.patch 101_java_install_path.patch > tmp2.patch 
combinediff tmp2.patch 106_install_doxygen_scripts_in_nodoc_build.patch > tmp1.patch 
combinediff tmp1.patch 108_Doxygen-use-mathjax.patch > tmp2.patch 
combinediff tmp2.patch 109_java-jar-nonjavafiles.patch > tmp1.patch 
combinediff tmp1.patch 110_python-371.patch > tmp2.patch 
combinediff tmp2.patch 111_fix_perl.patch > tmp1.patch 
combinediff tmp1.patch 112_riscv_support.patch > tmp2.patch 
combinediff tmp2.patch vtk8-113_fix_python_equal.patch > tmp1.patch
combinediff tmp1.patch 115_support-gcc10.patch > tmp2.patch 
combinediff tmp2.patch mysq8_my_bool.patch > tmp1.patch 
combinediff tmp1.patch 3edc0de2b04ae1e100c229e592d6b9fa94f2915a.patch > tmp2.patch 
combinediff tmp2.patch 581d9eb874b2b80a3fb21c739a96fa6f955ffb5e.patch > tmp1.patch 
combinediff tmp1.patch vtk8-gcc-11-exodus.patch > vtk8.2.patch

rm tmp1.patch tmp2.patch
