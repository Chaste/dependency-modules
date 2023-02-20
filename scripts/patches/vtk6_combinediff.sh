#!/bin/bash

# https://sources.debian.org/patches/vtk6/6.3.0%2Bdfsg2-8.1/

wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/10_allpatches.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/20_soversion-sharedlib.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/30_matplotlib.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/40_use_system_sqlite.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/50_use_system_utf8.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/60_use_system_mpi4py.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/70_fix_ftbfs_gcc49.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/80_fix_arm_compilation.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/90_gdal-2.0.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/95_ffmpeg_2.9.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/97_fix_latex_doxygen.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/100_javac-heap.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/101_java_install_path.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/104_fix_gcc_version_6.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/105_unforce_embedded_glew.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/106_install_doxygen_scripts_in_nodoc_build.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/99-hdf5-1.10-compatibility
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/108_Doxygen-use-mathjax.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/109_infovis_boost.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/110_remove_nonfree_from_build.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/120_fix_ftbfs_qtpainter.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/3edc0de2b04ae1e100c229e592d6b9fa94f2915a.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/581d9eb874b2b80a3fb21c739a96fa6f955ffb5e.patch
wget -nc https://sources.debian.org/data/main/v/vtk6/6.3.0%2Bdfsg2-8.1/debian/patches/new-freetype.patch

combinediff 10_allpatches.patch 20_soversion-sharedlib.patch > tmp1.patch
combinediff tmp1.patch 30_matplotlib.patch > tmp2.patch
combinediff tmp2.patch 70_fix_ftbfs_gcc49.patch > tmp1.patch
combinediff tmp2.patch 90_gdal-2.0.patch > tmp1.patch
combinediff tmp1.patch 95_ffmpeg_2.9.patch > tmp2.patch
combinediff tmp2.patch 97_fix_latex_doxygen.patch > tmp1.patch
combinediff tmp1.patch 100_javac-heap.patch > tmp2.patch 
combinediff tmp2.patch 101_java_install_path.patch > tmp1.patch 
combinediff tmp1.patch 105_unforce_embedded_glew.patch > tmp2.patch 
combinediff tmp2.patch 106_install_doxygen_scripts_in_nodoc_build.patch > tmp1.patch 
combinediff tmp1.patch 99-hdf5-1.10-compatibility > tmp2.patch 
combinediff tmp2.patch 108_Doxygen-use-mathjax.patch > tmp1.patch 
combinediff tmp1.patch 109_infovis_boost.patch > tmp2.patch 
combinediff tmp2.patch 110_remove_nonfree_from_build.patch > tmp1.patch 
combinediff tmp1.patch 120_fix_ftbfs_qtpainter.patch > tmp2.patch 
combinediff tmp2.patch 3edc0de2b04ae1e100c229e592d6b9fa94f2915a.patch > tmp1.patch 
combinediff tmp1.patch 581d9eb874b2b80a3fb21c739a96fa6f955ffb5e.patch > tmp2.patch 
combinediff tmp2.patch new-freetype.patch > vtk6.patch 
rm tmp1.patch tmp2.patch
