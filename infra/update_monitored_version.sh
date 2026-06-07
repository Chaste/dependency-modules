#!/bin/bash -eu

# Update last_built for a dependency in infra/monitored-versions.json.

usage()
{
  echo "Usage: $(basename "$0") --dependency=name --version=version [--manifest=path]"
  exit 1
}

script_dir="$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )"
manifest="${script_dir}/../infra/monitored-versions.json"
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
    --manifest=*)
      manifest=$(expr "x$option" : "x--manifest=\(.*\)")
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

if [ ! -f "${manifest}" ]; then
  echo "ERROR: manifest not found: ${manifest}" 1>&2
  exit 1
fi

tmp="$(mktemp)"
jq --arg dep "${dependency}" --arg ver "${version}" \
  '.[$dep].last_built = $ver' "${manifest}" > "${tmp}"
mv "${tmp}" "${manifest}"

echo "Updated ${dependency} last_built to ${version}"
