#!/bin/bash -eu

usage()
{
    echo 'Usage: '"$(basename $0)"' [--scope={org|repo}] --org=org_name [--repo=repo_name]'
    echo '         [--name=runner_name] [--labels=foo,bar]  [--group=runner_group]'
    echo '         --runner_dir=dir [--work_dir=dir]'      
}

throw_error()
{
    echo "ERROR: $@" 1>&2
    exit 1
}

# Parse arguments
scope=
org=
repo=
name=
labels=
group=
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
        --name=*)
            name=$(expr "x${option}" : "x--name=\(.*\)")
            ;;
        --labels=*)
            labels=$(expr "x${option}" : "x--labels=\(.*\)")
            ;;
        --group=*)
            group=$(expr "x${option}" : "x--group=\(.*\)")
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
scope="${scope:-repo}"

if [[ ! ("${scope}" = "org" 
      || "${scope}" = "repo") ]]; then
    usage
    throw_error "Unknown scope: '${scope}'; expected 'org' or 'repo'"
fi

if [ -z "${org}" ]; then
    usage
    throw_error "--org not specified"
fi

if [ "${scope}" = "repo" ]; then
    if [ -z ${repo} ]; then
        usage
        throw_error "--repo not specified"
    fi
fi

if [ -z "${runner_dir}" ]; then
    usage
    throw_error "--runner_dir not specified"
fi

name="${name:-$(openssl rand -hex 6)}"

labels="${labels:-self-hosted}"

group="${group:-Default}"

work_dir="${work_dir:-${HOME}/_work}"

# Get access token
for i in {0..2}; do
    echo "Enter access token:"
    read -s pat
    if [ -n "${pat}" ]; then
        break
    fi
done

if [ -z "${pat}" ]; then
    throw_error "Access token not provided"
fi

# Set urls for config and api
cfg_url=
api_url=
if [ "${scope}" = "org" ]; then
    cfg_url="https://github.com/${org}"
    api_url="https://api.github.com/orgs/${org}/actions/runners/registration-token"

elif [ "${scope}" = "repo" ]; then
    cfg_url="https://github.com/${org}/${repo}"
    api_url="https://api.github.com/repos/${org}/${repo}/actions/runners/registration-token"
fi

# Get registration token
token="$(curl -X POST -fsS \
-H "Accept: application/vnd.github+json" \
-H "Authorization: token ${pat}" \
"${api_url}")"
token="$(echo ${token} | jq -r .token)"

unset pat

# Configure actions-runner
mkdir -p ${work_dir}

${runner_dir}/config.sh \
    --unattended \
    --url "${cfg_url}" \
    --token "${token}" \
    --name "${name}" \
    --runnergroup "${group}" \
    --labels "${labels}" \
    --work "${work_dir}" \
    --replace

unset token
