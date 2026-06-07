#!/bin/bash -eu

# Parse a build workflow run name into dependency and version.
# Example inputs:
#   Build Boost 1.83.0
#   Build PETSc 3.19.2/linux-gnu

run_name="$1"

if [ -z "${run_name}" ]; then
  echo "ERROR: run name required" 1>&2
  exit 1
fi

case "${run_name}" in
  "Build Boost "*)
    echo "dependency=boost"
    echo "version=${run_name#Build Boost }"
    ;;
  "Build HDF5 "*)
    echo "dependency=hdf5"
    echo "version=${run_name#Build HDF5 }"
    ;;
  "Build PETSc "*)
    echo "dependency=petsc"
    echo "version=${run_name#Build PETSc }" | cut -d/ -f1
    ;;
  "Build SUNDIALS "*)
    echo "dependency=sundials"
    echo "version=${run_name#Build SUNDIALS }"
    ;;
  "Build VTK "*)
    echo "dependency=vtk"
    echo "version=${run_name#Build VTK }"
    ;;
  "Build Xerces-C "*)
    echo "dependency=xercesc"
    echo "version=${run_name#Build Xerces-C }"
    ;;
  "Build XSD "*)
    echo "dependency=xsd"
    echo "version=${run_name#Build XSD }"
    ;;
  *)
    echo "ERROR: unrecognized run name: ${run_name}" 1>&2
    exit 1
    ;;
esac
