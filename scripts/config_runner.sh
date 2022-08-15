#!/bin/bash -eu

usage()
{
    echo 'Usage: '"$(basename $0)"' [--runner_dir=dir] [--scope={org|repo}] [--org=org_name]'
    echo '         [--repo=repo_name] [--name=runner_name] [--labels=foo,bar]'
    echo '         [--group=runner_group] [--work_dir=dir] [--unattended]'      
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
unattended=

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
        --unattended*)
            unattended="--unattended"
            ;;
        *)
            throw_error "unknown option: ${option}"
            ;;
    esac
done

# Get scope
if [[ (-z "${scope}") && (-z "${unattended}") ]]; then
    echo -n "Enter runner scope {org|repo} (default=org): "
    read scope
fi

scope="${scope:-org}"

if [[ ! ("${scope}" = "org" 
      || "${scope}" = "repo") ]]; then
    usage
    throw_error "unknown scope: '${scope}'; expected 'org' or 'repo'"
fi

# Get org
if [[ (-z "${org}") && (-z "${unattended}") ]]; then
    echo -n "Enter org name: "
    read org
fi

if [ -z "${org}" ]; then
    usage
    throw_error "org not specified"
fi

# Get repo
if [ "${scope}" = "repo" ]; then
    if [[ (-z "${repo}") && (-z "${unattended}") ]]; then
        echo -n "Enter repo name: "
        read repo
    fi

    if [ -z ${repo} ]; then
        usage
        throw_error "repo not specified"
    fi
fi

# Get runner_dir
if [[ (-z "${runner_dir}") && (-z "${unattended}") ]]; then
    echo -n "Enter path to runner: "
    read runner_dir
fi

if [ -z "${runner_dir}" ]; then
    usage
    throw_error "runner_dir not specified"
fi

# Get personal access token
if [[ (-z "${PA_TOKEN}") && (-z "${unattended}") ]]; then
    echo -n "Enter access token: "
    read -s PA_TOKEN
fi

if [ -z "${PA_TOKEN}" ]; then
    throw_error "access token not provided"
fi

if [ -n "${unattended}" ]; then
    name="${name:-$(openssl rand -hex 6)}"

    labels="${labels:-self-hosted}"

    group="${group:-Default}"

    work_dir="${work_dir:-${HOME}/_work}"
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
-H "Authorization: token ${PA_TOKEN}" \
"${api_url}")"
token="$(echo ${token} | jq -r .token)"

unset PA_TOKEN

# Configure actions-runner
mkdir -p ${work_dir}

${runner_dir}/config.sh \
    --url "${cfg_url}" \
    --token "${token}" \
    --name "${name}" \
    --runnergroup "${group}" \
    --labels "${labels}" \
    --work "${work_dir}" \
    --replace ${unattended}

unset token
