#!/bin/bash

# Shared functions for infra scripts. Meant to be sourced, not executed directly.

_infra_dir="$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )"
. "${_infra_dir}/../scripts/common.sh"

versions_dir="${_infra_dir}/versions"

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

set_output()
{
  local key="$1"
  local value="$2"
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    {
      echo "${key}=${value}"
    } >> "${GITHUB_OUTPUT}"
  fi
}

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

fetch_latest_sundials()
{
  local tag
  tag=$(curl -fsSL "https://api.github.com/repos/LLNL/sundials/releases/latest" | jq -r '.tag_name')
  normalize_sundials_tag "${tag}"
}

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

check_dependency()
{
  local dep="$1"
  local latest="$2"
  local last_built
  local build_key="${dep}_build"
  local version_key="${dep}_version"

  if [ -z "${latest}" ]; then
    echo "ERROR: failed to determine latest version for ${dep}" 1>&2
    exit 1
  fi

  last_built=$(read_manifest_field "${dep}" "last_built")
  if [ -z "${last_built}" ]; then
    echo "ERROR: missing last_built for ${dep} in ${versions_dir}/${dep}.json" 1>&2
    exit 1
  fi

  echo "${dep}: latest=${latest} last_built=${last_built}"

  if version_gt "${latest}" "${last_built}"; then
    set_output "${build_key}" "true"
    set_output "${version_key}" "${latest}"
    echo "  -> build required"
    return 0
  fi

  set_output "${build_key}" "false"
  echo "  -> up to date"
  return 1
}
