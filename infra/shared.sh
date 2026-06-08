#!/bin/bash

# Shared functions for infra scripts. Meant to be sourced, not executed directly.

_infra_dir="$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )"
. "${_infra_dir}/../scripts/common.sh"

versions_dir="${_infra_dir}/versions"

# Read a field from a dependency's version file.
#
# Usage: read_manifest_field <dependency> <field>
#
# Returns: the field value, or empty if the file or field does not exist
#
# Examples:
# `read_manifest_field boost last_built` -> 1.83.0
# `read_manifest_field petsc arch` -> linux-gnu
read_manifest_field()
{
  local dep="$1"
  local field="$2"
  local file="${versions_dir}/${dep}.json"
  if [ ! -f "${file}" ]; then
    echo ""
    return 0
  fi
  jq -r ".${field} // empty" "${file}"
}

# Write a key=value pair to GITHUB_OUTPUT when running in GitHub Actions.
#
# Usage: set_gh_output <key> <value>
#
# Examples:
# `set_gh_output boost_build true`
# `set_gh_output boost_version 1.84.0`
set_gh_output()
{
  local key="$1"
  local value="$2"
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    {
      echo "${key}=${value}"
    } >> "${GITHUB_OUTPUT}"
  fi
}

# Fetch the latest stable Boost release version from archives.boost.io.
#
# Usage: fetch_latest_boost
#
# Returns: the latest stable version string (e.g. 1.84.0)
fetch_latest_boost()
{
  local html version norm versions=""
  html=$(curl -fsSL "https://archives.boost.io/release/")
  while IFS= read -r version; do
    norm=$(normalize_boost_version "${version}" || true)
    if [ -n "${norm}" ]; then
      versions="${versions} ${norm}"
    fi
  done < <(echo "${html}" | grep -oE 'href="[0-9]+\.[0-9]+\.[0-9]+/"' | sed -E 's|href="||;s|/"||')
  max_version ${versions}
}

# Fetch the latest stable HDF5 release version from the HDFGroup GitHub tags.
#
# Usage: fetch_latest_hdf5
#
# Returns: the latest stable version string (e.g. 1.14.6)
fetch_latest_hdf5()
{
  local tags norm versions="" tag
  tags=$(curl -fsSL "https://api.github.com/repos/HDFGroup/hdf5/tags?per_page=100" | jq -r '.[].name')
  while IFS= read -r tag; do
    norm=$(normalize_hdf5_tag "${tag}" || true)
    if [ -n "${norm}" ]; then
      versions="${versions} ${norm}"
    fi
  done <<< "${tags}"
  max_version ${versions}
}

# Fetch the latest stable PETSc release version from the GitLab tags.
#
# Usage: fetch_latest_petsc
#
# Returns: the latest stable version string (e.g. 3.21.0)
fetch_latest_petsc()
{
  local tags norm versions="" tag
  tags=$(curl -fsSL "https://gitlab.com/api/v4/projects/petsc%2Fpetsc/repository/tags?per_page=100" | jq -r '.[].name')
  while IFS= read -r tag; do
    norm=$(normalize_petsc_tag "${tag}" || true)
    if [ -n "${norm}" ]; then
      versions="${versions} ${norm}"
    fi
  done <<< "${tags}"
  max_version ${versions}
}

# Fetch the latest stable SUNDIALS release version from the GitHub latest release.
#
# Usage: fetch_latest_sundials
#
# Returns: the latest stable version string (e.g. 7.1.0)
fetch_latest_sundials()
{
  local tag
  tag=$(curl -fsSL "https://api.github.com/repos/LLNL/sundials/releases/latest" | jq -r '.tag_name')
  normalize_sundials_tag "${tag}"
}

# Fetch the latest stable VTK release version from the Kitware GitLab tags.
#
# Usage: fetch_latest_vtk
#
# Returns: the latest stable version string (e.g. 9.3.1)
fetch_latest_vtk()
{
  local tags norm versions="" tag
  tags=$(curl -fsSL "https://gitlab.kitware.com/api/v4/projects/vtk%2Fvtk/repository/tags?per_page=100" | jq -r '.[].name')
  while IFS= read -r tag; do
    norm=$(normalize_vtk_tag "${tag}" || true)
    if [ -n "${norm}" ]; then
      versions="${versions} ${norm}"
    fi
  done <<< "${tags}"
  max_version ${versions}
}

# Fetch the latest stable Xerces-C release version from the Apache GitHub tags.
#
# Usage: fetch_latest_xercesc
#
# Returns: the latest stable version string (e.g. 3.2.5)
fetch_latest_xercesc()
{
  local tags norm versions="" tag
  tags=$(curl -fsSL "https://api.github.com/repos/apache/xerces-c/tags?per_page=100" | jq -r '.[].name')
  while IFS= read -r tag; do
    norm=$(normalize_xercesc_tag "${tag}" || true)
    if [ -n "${norm}" ]; then
      versions="${versions} ${norm}"
    fi
  done <<< "${tags}"
  max_version ${versions}
}

# Fetch the latest stable XSD release version from the codesynthesis GitHub tags.
#
# Usage: fetch_latest_xsd
#
# Returns: the latest stable version string (e.g. 4.2.0)
fetch_latest_xsd()
{
  local tags norm versions="" tag
  tags=$(curl -fsSL "https://api.github.com/repos/codesynthesis-com/xsd/tags?per_page=100" | jq -r '.[].name')
  while IFS= read -r tag; do
    norm=$(normalize_xsd_tag "${tag}" || true)
    if [ -n "${norm}" ]; then
      versions="${versions} ${norm}"
    fi
  done <<< "${tags}"
  max_version ${versions}
}

# Check whether the latest upstream version is newer than the last built version.
#
# Usage: check_dependency <dependency> <latest>
#
# Returns:
#  true  if latest > last_built (build required)
#  false if latest <= last_built (up to date)
#
# Examples:
# `check_dependency boost 1.84.0`  -> true (if last_built is 1.83.0)
# `check_dependency boost 1.83.0`  -> false (if last_built is 1.83.0)
check_dependency()
{
  local dep="$1"
  local latest="$2"
  local last_built

  if [ -z "${latest}" ]; then
    echo "ERROR: failed to determine latest version for ${dep}" 1>&2
    exit 1
  fi

  last_built=$(read_manifest_field "${dep}" "last_built")
  if [ -z "${last_built}" ]; then
    echo "ERROR: missing last_built for ${dep} in ${versions_dir}/${dep}.json" 1>&2
    exit 1
  fi

  version_gt "${latest}" "${last_built}"
}
