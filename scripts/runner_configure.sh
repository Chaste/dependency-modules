#!/bin/bash -eu

throw_error()
{
    echo "ERROR: $@" 1>&2
    exit 1
}

# Get unattended
unattended="${RUNNER_UNATTENDED:-}"

if [ -z "${unattended}" ]; then
    unattended=
elif [ "${unattended}" -eq 0 ]; then
    unattended=
else
    unattended="--unattended"
fi

# Get runner_dir
runner_dir="${RUNNER_DIR:-}"

if [[ (-z "${runner_dir}") && (-z "${unattended}") ]]; then
    echo -n "Enter path to actions-runner: "
    read runner_dir
fi

if [ -z "${runner_dir}" ]; then
    throw_error "RUNNER_DIR not specified"
fi

# Get personal access token
pa_token="${RUNNER_PA_TOKEN-}"
unset RUNNER_PA_TOKEN

if [[ (-z "${pa_token}") && (-z "${unattended}") ]]; then
    echo -n "Enter access token: "
    read -s pa_token
    echo
fi

if [ -z "${pa_token}" ]; then
    throw_error "RUNNER_PA_TOKEN not provided"
fi

# Get scope
scope="${RUNNER_SCOPE:-}"

if [[ (-z "${scope}") && (-z "${unattended}") ]]; then
    echo -n "Enter the runner scope (org or repo): [press Enter for org] "
    read scope
fi

scope="${scope:-org}"

if [[ ! ("${scope}" = "org" 
      || "${scope}" = "repo") ]]; then
    throw_error "unknown RUNNER_SCOPE: '${scope}'; expected 'org' or 'repo'"
fi

# Get org
org="${RUNNER_ORG:-}"

if [[ (-z "${org}") && (-z "${unattended}") ]]; then
    echo -n "Enter the org/owner name: "
    read org
fi

if [ -z "${org}" ]; then
    throw_error "RUNNER_ORG not specified"
fi

# Get repo
repo="${RUNNER_REPO:-}"

if [ "${scope}" = "repo" ]; then
    if [[ (-z "${repo}") && (-z "${unattended}") ]]; then
        echo -n "Enter the repo name: "
        read repo
    fi

    if [ -z ${repo} ]; then
        throw_error "RUNNER_REPO not specified"
    fi
fi

# Runner removal
remove="${RUNNER_REMOVE:-}"

if [ -n "${remove}" ]; then
    # Set urls for remove api
    rm_url=
    if [ "${scope}" = "org" ]; then
        rm_url="https://api.github.com/orgs/${org}/actions/runners/remove-token"

    elif [ "${scope}" = "repo" ]; then
        rm_url="https://api.github.com/repos/${org}/${repo}/actions/runners/remove-token"
    fi

    # Get remove token from api
    rm_token="$(curl -X POST -fsS -H "Accept: application/vnd.github+json" -H "Authorization: token ${pa_token}" "${rm_url}")"
    rm_token="$(echo ${rm_token} | jq -r .token)"
    unset pa_token

    # Remove runner
    ${runner_dir}/config.sh remove --token "${rm_token}"
    unset rm_token
    exit 0
fi

# Set urls for configuration and registration api
cfg_url=
reg_url=
if [ "${scope}" = "org" ]; then
    cfg_url="https://github.com/${org}"
    reg_url="https://api.github.com/orgs/${org}/actions/runners/registration-token"

elif [ "${scope}" = "repo" ]; then
    cfg_url="https://github.com/${org}/${repo}"
    reg_url="https://api.github.com/repos/${org}/${repo}/actions/runners/registration-token"
fi

# Get registration token from api
reg_token="$(curl -X POST -fsS -H "Accept: application/vnd.github+json" -H "Authorization: token ${pa_token}" "${reg_url}")"
reg_token="$(echo ${reg_token} | jq -r .token)"
unset pa_token

# Get name, labels, group
name="${RUNNER_NAME:-}"
labels="${RUNNER_LABELS:-}"
group="${RUNNER_GROUP:-}"

# Set unattended defaults
if [ -n "${unattended}" ]; then
    name="${name:-$(openssl rand -hex 6)}"
    labels="${labels:-self-hosted}"
    group="${group:-Default}"
fi

# Get work_dir
work_dir="${RUNNER_WORK_DIR:-${HOME}/_work}"

# Configure actions-runner
mkdir -p ${work_dir}

${runner_dir}/config.sh \
    --url "${cfg_url}" \
    --token "${reg_token}" \
    --name "${name}" \
    --runnergroup "${group}" \
    --labels "${labels}" \
    --work "${work_dir}" \
    --replace ${unattended}

unset reg_token
