#!/bin/bash -eu

# Check upstream dependency versions against infra/versions/<dependency>.json.
# Emits GitHub Actions outputs when GITHUB_OUTPUT is set.

usage()
{
  echo "Usage: $(basename "$0") [--versions-dir=path]"
  exit 1
}

script_dir="$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )"
. "${script_dir}/shared.sh"

for option; do
  case $option in
    --versions-dir=*)
      versions_dir=$(expr "x$option" : "x--versions-dir=\(.*\)")
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo "Unknown option: $option" 1>&2
      usage
      ;;
  esac
done

if [ ! -d "${versions_dir}" ]; then
  echo "ERROR: versions directory not found: ${versions_dir}" 1>&2
  exit 1
fi

matrix_items=()
any_build=false

process_dependency()
{
  local dep="$1"
  local latest="$2"

  if check_dependency "${dep}" "${latest}"; then
    any_build=true
    matrix_items+=("{\"dependency\":\"${dep}\",\"version\":\"${latest}\"}")
  fi
}

process_dependency "boost" "$(fetch_latest_boost)"
process_dependency "hdf5" "$(fetch_latest_hdf5)"
process_dependency "petsc" "$(fetch_latest_petsc)"
process_dependency "sundials" "$(fetch_latest_sundials)"
process_dependency "vtk" "$(fetch_latest_vtk)"
process_dependency "xercesc" "$(fetch_latest_xercesc)"
process_dependency "xsd" "$(fetch_latest_xsd)"

if [ "${any_build}" = true ]; then
  matrix_json="[$(IFS=,; echo "${matrix_items[*]}")]"
  set_output "matrix" "${matrix_json}"
  set_output "any_build" "true"
  echo "Build matrix: ${matrix_json}"
else
  set_output "matrix" "[]"
  set_output "any_build" "false"
  echo "All dependencies up to date."
fi
