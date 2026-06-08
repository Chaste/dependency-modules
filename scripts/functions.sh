#!/bin/bash -eu

# Split version string, setting minor and patch to 0 if missing.
#
# Usage: split_version <version>
#
# Returns: version major minor patch[ rc]
#
# Examples:
# `split_version 1` -> 1.0.0 1 0 0
# `split_version 1.2` -> 1.2.0 1 2 0
# `split_version 1.2.3` -> 1.2.3 1 2 3
# `split_version 1.2.3-rc1` -> 1.2.3-rc1 1 2 3 rc1
split_version()
{
  local varr="" parr="" major="" minor="0" patch="0" rc=""
  varr=(${1//\./ })  # split version string on '.'
  major=${varr[0]}
  if [ ${#varr[@]} -ge 2 ]; then
    minor=${varr[1]}
    if [ ${#varr[@]} -ge 3 ]; then
      parr=(${varr[2]//-/ })  # split patch substring on '-'
      patch=${parr[0]}
      if [ ${#parr[@]} -ge 2 ]; then
        rc=${parr[1]}
      fi
    fi
  fi
  if [ -z "${rc}" ]; then
    echo "${major}.${minor}.${patch}" "${major}" "${minor}" "${patch}"
  else
    echo "${major}.${minor}.${patch}-${rc}" "${major}" "${minor}" "${patch}" "${rc}"
  fi
}

# Compare two version strings, ignoring release candidate.
#
# Usage: compare_version <version_x> <version_y>
#
# Returns:
#  -1 if version_x < version_y
#   0 if version_x == version_y
#   1 if version_x > version_y
#
# Examples:
# `compare_version 1.2.3 1.2.3` -> 0
# `compare_version 1.2.3 1.2.4` -> -1
# `compare_version 1.2.4 1.2.3` -> 1
compare_version()
{
  local arr_x maj_x min_x patch_x
  local arr_y maj_y min_y patch_y

  read -r _ maj_x min_x patch_x _ < <(split_version $1)
  read -r _ maj_y min_y patch_y _ < <(split_version $2)

  arr_x=("${maj_x}" "${min_x}" "${patch_x}")
  arr_y=("${maj_y}" "${min_y}" "${patch_y}")

  for i in $(seq 0 2); do
    if ((arr_x[i] > arr_y[i])); then
      echo 1
      return
    elif ((arr_x[i] < arr_y[i])); then
      echo -1
      return
    fi
  done

  echo 0
}

# Check if version_x is equal to version_y.
#
# Usage: version_eq <version_x> <version_y>
#
# Returns: true if version_x == version_y, false otherwise
#
# Examples:
# `version_eq 1.2.3 1.2.3` -> true
# `version_eq 1.2.3 1.2.4` -> false
version_eq()
{
  test "$(compare_version $1 $2)" -eq 0
}

# Check if version_x is less than version_y.
#
# Usage: version_lt <version_x> <version_y>
#
# Returns: true if version_x < version_y, false otherwise
#
# Examples:
# `version_lt 1.2.3 1.2.3` -> false
# `version_lt 1.2.3 1.2.4` -> true
version_lt()
{
  test "$(compare_version $1 $2)" -eq -1
}

# Check if version_x is greater than version_y.
#
# Usage: version_gt <version_x> <version_y>
#
# Returns: true if version_x > version_y, false otherwise
#
# Examples:
# `version_gt 1.2.3 1.2.3` -> false
# `version_gt 1.2.4 1.2.3` -> true
version_gt()
{
  test "$(compare_version $1 $2)" -eq 1
}

# Check if version_x is less than or equal to version_y.
#
# Usage: version_le <version_x> <version_y>
#
# Returns: true if version_x <= version_y, false otherwise
#
# Examples:
# `version_le 1.2.3 1.2.3` -> true
# `version_le 1.2.3 1.2.4` -> true
# `version_le 1.2.4 1.2.3` -> false
version_le()
{
  ! version_gt $1 $2
}

# Check if version_x is greater than or equal to version_y.
#
# Usage: version_ge <version_x> <version_y>
#
# Returns: true if version_x >= version_y, false otherwise
#
# Examples:
# `version_ge 1.2.3 1.2.3` -> true
# `version_ge 1.2.4 1.2.3` -> true
# `version_ge 1.2.3 1.2.4` -> false
version_ge()
{
  ! version_lt $1 $2
}

# Return the greatest of the given version strings.
#
# Usage: max_version <version>...
#
# Returns: the highest version string, or empty if no valid versions are given
#
# Examples:
# `max_version 1.0.0 1.1.0 1.2.0` -> 1.2.0
# `max_version 1.83.0 1.84.0` -> 1.84.0
max_version()
{
  local max="" ver
  for ver in "$@"; do
    if [ -z "${ver}" ]; then
      continue
    fi
    if [ -z "${max}" ] || version_gt "${ver}" "${max}"; then
      max="${ver}"
    fi
  done
  echo "${max}"
}

# Check if a string is a semantic version of the form X[.Y[.Z]][-rc].
#
# Usage: is_semver <string>
#
# Returns: true if the string matches, false otherwise
#
# Examples:
# `is_semver 1.2.3` -> true
# `is_semver 1.2.3-rc1` -> true
# `is_semver develop` -> false
is_semver()
{
  [[ "$1" =~ ^[0-9]+(\.[0-9]+){0,2}(-[A-Za-z0-9]+)?$ ]]
}

# Normalize a Boost version string to X.Y.Z.
# Strips optional 'boost-' or 'v' prefix.
#
# Usage: normalize_boost_version <version>
#
# Returns: X.Y.Z version string, or empty if not a recognized release
#
# Examples:
# `normalize_boost_version 1.83.0` -> 1.83.0
# `normalize_boost_version v1.83.0` -> 1.83.0
# `normalize_boost_version boost-1.83.0` -> 1.83.0
# `normalize_boost_version boost_1_83_0` -> (empty)
normalize_boost_version()
{
  local version="$1"
  version="${version#boost-}"
  version="${version#v}"
  if is_semver "${version}"; then
    read -r version _ < <(split_version "${version}")
    echo "${version}"
  fi
}

# Normalize an HDF5 git tag to X.Y.Z.
# Accepts tags of the form hdf5-X.Y.Z, hdf5_X.Y.Z, or plain X.Y.Z.
#
# Usage: normalize_hdf5_tag <tag>
#
# Returns: X.Y.Z version string, or empty if not a recognized release tag
#
# Examples:
# `normalize_hdf5_tag hdf5-1.14.6` -> 1.14.6
# `normalize_hdf5_tag hdf5_1.12.3` -> 1.12.3
# `normalize_hdf5_tag vms_last_support_1_8` -> (empty)
normalize_hdf5_tag()
{
  local tag="$1"
  local version=""

  case "${tag}" in
    hdf5-[0-9]*.[0-9]*.[0-9]*)
      version="${tag#hdf5-}"
      ;;
    hdf5_[0-9]*.[0-9]*.[0-9]*)
      version="${tag#hdf5_}"
      ;;
    hdf5-[0-9]*.[0-9]*)
      version="${tag#hdf5-}"
      ;;
    [0-9]*.[0-9]*.[0-9]*)
      version="${tag}"
      ;;
  esac

  if [ -n "${version}" ] && is_semver "${version}"; then
    read -r version _ < <(split_version "${version}")
    echo "${version}"
  fi
}

# Normalize a PETSc git tag to X.Y.Z.
# Strips optional 'v' prefix. Release candidates are excluded.
#
# Usage: normalize_petsc_tag <tag>
#
# Returns: X.Y.Z version string, or empty if not a recognized release tag
#
# Examples:
# `normalize_petsc_tag v3.19.6` -> 3.19.6
# `normalize_petsc_tag v3.19.6-rc.1` -> (empty)
normalize_petsc_tag()
{
  local tag="$1"
  local version="${tag#v}"

  if is_semver "${version}"; then
    read -r version _ < <(split_version "${version}")
    echo "${version}"
  fi
}

# Normalize a SUNDIALS git tag to X.Y.Z.
# Strips optional 'v' prefix.
#
# Usage: normalize_sundials_tag <tag>
#
# Returns: X.Y.Z version string, or empty if not a recognized release tag
#
# Examples:
# `normalize_sundials_tag v6.4.1` -> 6.4.1
# `normalize_sundials_tag v7.7.0` -> 7.7.0
normalize_sundials_tag()
{
  local tag="$1"
  local version="${tag#v}"

  if is_semver "${version}"; then
    read -r version _ < <(split_version "${version}")
    echo "${version}"
  fi
}

# Normalize a VTK git tag to X.Y.Z.
# Strips optional 'v' prefix. Only accepts exact X.Y.Z form (no rc suffixes).
#
# Usage: normalize_vtk_tag <tag>
#
# Returns: X.Y.Z version string, or empty if not a recognized release tag
#
# Examples:
# `normalize_vtk_tag v9.3.1` -> 9.3.1
# `normalize_vtk_tag vms_last_support_trunk` -> (empty)
normalize_vtk_tag()
{
  local tag="$1"
  local version="${tag#v}"

  if [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "${version}"
  fi
}

# Normalize a Xerces-C git tag to X.Y.Z.
# Accepts tags of the form Xerces-C_X_Y_Z, vX.Y.Z, or plain X.Y.Z.
#
# Usage: normalize_xercesc_tag <tag>
#
# Returns: X.Y.Z version string, or empty if not a recognized release tag
#
# Examples:
# `normalize_xercesc_tag Xerces-C_3_2_4` -> 3.2.4
# `normalize_xercesc_tag v3.2.4` -> 3.2.4
normalize_xercesc_tag()
{
  local tag="$1"
  local version=""

  case "${tag}" in
    Xerces-C_*)
      version="${tag#Xerces-C_}"
      version="${version//_/.}"
      ;;
    v[0-9]*.[0-9]*.[0-9]*)
      version="${tag#v}"
      ;;
    [0-9]*.[0-9]*.[0-9]*)
      version="${tag}"
      ;;
  esac

  if [ -n "${version}" ] && is_semver "${version}"; then
    read -r version _ < <(split_version "${version}")
    echo "${version}"
  fi
}

# Normalize an XSD git tag to X.Y.Z.
# Strips optional 'v' prefix.
#
# Usage: normalize_xsd_tag <tag>
#
# Returns: X.Y.Z version string, or empty if not a recognized release tag
#
# Examples:
# `normalize_xsd_tag v4.0.0` -> 4.0.0
# `normalize_xsd_tag v4.2.1` -> 4.2.1
normalize_xsd_tag()
{
  local tag="$1"
  local version="${tag#v}"

  if is_semver "${version}"; then
    read -r version _ < <(split_version "${version}")
    echo "${version}"
  fi
}
