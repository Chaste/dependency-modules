#!/bin/bash -eu

usage()
{
    echo 'Usage: '"$(basename $0)"' [--install_dir=dir]'
}

throw_error()
{
    usage
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
            throw_error "Unknown option: ${option}"
            ;;
    esac
done

# Sanitize arguments
install_dir="${install_dir:-${HOME}/actions-runner}"

# Get latest version of actions-runner
curl -o /tmp/latest.json -fsSL https://api.github.com/repos/actions/runner/releases/latest
version="$(jq -r '.tag_name' /tmp/latest.json | cut -c2-)"
rm -f /tmp/latest.json

mkdir -p ${install_dir}
curl -o /tmp/actions-runner.tar.gz -L "https://github.com/actions/runner/releases/download/v${version}/actions-runner-linux-x64-${version}.tar.gz"
tar -xzf /tmp/actions-runner.tar.gz -C ${install_dir}
rm -f /tmp/actions-runner.tar.gz

${install_dir}/bin/installdependencies.sh