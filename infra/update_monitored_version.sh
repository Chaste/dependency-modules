#!/bin/bash -eu

# Update last_built for a dependency in infra/versions/<dependency>.json.

usage()
{
  echo "Usage: $(basename "$0") --dependency=name --version=version [--versions-dir=path]"
  exit 1
}

script_dir="$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )"
versions_dir="${script_dir}/versions"
dependency=
version=

for option; do
  case $option in
    --dependency=*)
      dependency=$(expr "x$option" : "x--dependency=\(.*\)")
      ;;
    --version=*)
      version=$(expr "x$option" : "x--version=\(.*\)")
      ;;
    --versions-dir=*)
      versions_dir=$(expr "x$option" : "x--versions-dir=\(.*\)")
      ;;
    *)
      echo "Unknown option: $option" 1>&2
      usage
      ;;
  esac
done

if [ -z "${dependency}" ] || [ -z "${version}" ]; then
  usage
fi

manifest="${versions_dir}/${dependency}.json"

if [ ! -f "${manifest}" ]; then
  echo "ERROR: version file not found: ${manifest}" 1>&2
  exit 1
fi

tmp="$(mktemp)"
jq --arg ver "${version}" '.last_built = $ver' "${manifest}" > "${tmp}"
mv "${tmp}" "${manifest}"

echo "Updated ${dependency} last_built to ${version}"
