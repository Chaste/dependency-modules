#!/bin/bash -eu

usage()
{
    echo 'Usage: '"$(basename $0)"' --scope={org|repo} --org=name [--repo=name] --token=token'
    echo '        [--runner_name=name] [--runner_labels=list]  [--runner-group=group]'
    echo '        [--runner_dir=dir] [--work_dir=dir]'
}

throw_error()
{
    usage
    echo "ERROR: $@" 1>&2
    exit 1
}

# Parse arguments
scope=
org=
repo=
token=
runner_name=
runner_labels=
runner_group=
runner_dir=
work_dir=

for option; do
    case $option in
        --scope=*)
            scope=$(expr "x${option}" : "x--scope=\(.*\)")
            ;;
        --org=*)
            org=$(expr "x${option}" : "x--org=\(.*\)")
            ;;
        --repo=*)
            repo=$(expr "x${option}" : "x--repo=\(.*\)")
            ;;
        --token=*)
            token=$(expr "x${option}" : "x--token=\(.*\)")
            ;;
        --runner_name=*)
            runner_name=$(expr "x${option}" : "x--runner_name=\(.*\)")
            ;;
        --runner_labels=*)
            runner_labels=$(expr "x${option}" : "x--runner_labels=\(.*\)")
            ;;
        --runner_group=*)
            runner_group=$(expr "x${option}" : "x--runner_group=\(.*\)")
            ;;
        --runner_dir=*)
            runner_dir=$(expr "x${option}" : "x--runner_dir=\(.*\)")
            ;;
        --work_dir=*)
            work_dir=$(expr "x${option}" : "x--work_dir=\(.*\)")
            ;;
        *)
            throw_error "Unknown option: ${option}"
            ;;
    esac
done

# Sanitize arguments
if [ -z "${scope}" ]; then throw_error "--scope not specified"; fi

if [[ ! ("${scope}" = "org" 
      || "${scope}" = "repo") ]]; then
    throw_error "Unknown scope: ${scope}. Expected 'org' or 'repo'"
fi

if [ "${scope}" = "repo" ]; then
    if [ -z ${repo} ]; then throw_error "--repo not specified" fi
fi

if [ -z "${org}" ]; then throw_error "--org not specified"; fi
if [ -z "${token}" ]; then throw_error "--token not specified"; fi

runner_name="${runner_name:-$(openssl rand -hex 6)}"
runner_labels="${runner_labels:-default}"
runner_group="${runner_group:-Default}"
runner_dir="${runner_dir:-${HOME}/actions-runner}"
work_dir="${work_dir:-${HOME}/_work}"

# Create directories
mkdir -p ${runner_dir}
mkdir -p ${work_dir}

# Download latest version of actions-runner
curl -o /tmp/latest.json -L https://api.github.com/repos/actions/runner/releases/latest
version="$(jq -r '.tag_name' /tmp/latest.json | cut -c2-)"
rm -f /tmp/latest.json

curl -o /tmp/actions-runner.tar.gz -L "https://github.com/actions/runner/releases/download/v${version}/actions-runner-linux-x64-${version}.tar.gz"
tar -xzf /tmp/actions-runner.tar.gz -C ${runner_dir}
rm -f /tmp/actions-runner.tar.gz

# Set config and registration urls
cfg_url=
reg_url=
if [ "${scope}" = "org" ]; then
    cfg_url="https://github.com/${org}"
    reg_url="https://api.github.com/orgs/${org}/actions/runners/registration-token"

elif [ "${scope}" = "repo" ]; then
    cfg_url="https://github.com/${org}/${repo}"
    reg_url="https://api.github.com/repos/${org}/${repo}/actions/runners/registration-token"
fi

# Get registration token
reg_token="$(curl -X POST \
-H "Accept: application/vnd.github+json" \
-H "Authorization: token ${PAT}" \
"${reg_url}")"
reg_token="$(echo ${reg_token} | jq -r .token)"

# Configure actions-runner
${runner_dir}/config.sh \
    --unattended \
    --replace \
    --url "${cfg_url}" \
    --token "${reg_token}" \
    --name "${runner_name}" \
    --labels "${runner_labels}" \
    --runnergroup "${runner_group}" \
    --work "${runner_workdir}"
