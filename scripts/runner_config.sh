#!/bin/bash -eu

throw_error()
{
    echo "ERROR: $@" 1>&2
    exit 1
}

# Get runner_dir
runner_dir="${RUNNER_DIR:-}"

if [ ! -d "${runner_dir}" ]; then
    echo -n "Enter path to actions-runner: "
    read runner_dir
fi

if [ ! -d "${runner_dir}" ]; then
    throw_error "RUNNER_DIR not specified"
fi

# Get scope
scope="${RUNNER_SCOPE:-}"

if [ -z "${scope}" ]; then
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

if [ -z "${org}" ]; then
    echo -n "Enter the org/owner name: "
    read org
fi

if [ -z "${org}" ]; then
    throw_error "RUNNER_ORG not specified"
fi

# Get repo
repo="${RUNNER_REPO:-}"

if [ "${scope}" = "repo" ]; then
    if [ -z "${repo}" ]; then
        echo -n "Enter the repo name: "
        read repo
    fi

    if [ -z ${repo} ]; then
        throw_error "RUNNER_REPO not specified"
    fi
fi

# Get personal access token
pa_token=
echo -n "Enter access token: "
read -s pa_token
echo

if [ -z "${pa_token}" ]; then
    throw_error "Access token not provided"
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

# Get name
name="${RUNNER_NAME:-$(openssl rand -hex 6)}"

# Get group
group="${RUNNER_GROUP:-Default}"

# Get labels
os_id="$(cat /etc/os-release | grep ^ID= | cut -d= -f2)"
os_ver="$(cat /etc/os-release | grep ^VERSION_CODENAME= | cut -d= -f2)"
labels="${RUNNER_LABELS:-self-hosted,${os_id}-${os_ver}}"

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
    --replace

unset reg_token
