#!/bin/bash -eu

usage()
{
    echo 'Usage: '"$(basename $0)"' [--install_dir=dir]'
}

throw_error()
{
    echo "ERROR: $@" 1>&2
    exit 1
}

# Parse arguments
install_dir=

for option; do
    case $option in
        --install_dir=*)
            install_dir=$(expr "x${option}" : "x--install_dir=\(.*\)")
            ;;
        *)
            usage
            throw_error "unknown option: ${option}"
            ;;
    esac
done

# Sanitize arguments
install_dir="${install_dir:-${HOME}/actions-runner}"

# Get latest version number
curl -fsS \
    -o /tmp/latest.json \
    -H "Accept: application/vnd.github+json" \
    -L https://api.github.com/repos/actions/runner/releases/latest

version="$(jq -r '.tag_name' /tmp/latest.json | cut -c2-)"
rm -f /tmp/latest.json

# Get actions-runner
mkdir -p ${install_dir}
curl -fsS \
    -o /tmp/actions-runner.tar.gz \
    -L "https://github.com/actions/runner/releases/download/v${version}/actions-runner-linux-x64-${version}.tar.gz"

tar -xzf /tmp/actions-runner.tar.gz -C ${install_dir}
rm -f /tmp/actions-runner.tar.gz

