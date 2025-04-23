#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
	echo "It's a PR"
elif [[ "${GITHUB_EVENT_NAME}" == "push" ]]; then
	echo "It's a Push"
elif [[ "${GITHUB_EVENT_NAME}" == "workflow_dispatch" ]]; then
  if [[ "${GENERATE_ASSETS}" == "true" ]]; then
    echo "It will generate the assets"
  else
  	echo "It's a Dispatch"
  fi
else
	echo "It's a Cron"
fi

if [[ "${GITHUB_ENV}" ]]; then
  echo "GITHUB_BRANCH=${GITHUB_BRANCH}" >> "${GITHUB_ENV}"
  echo "VSCODE_QUALITY=${VSCODE_QUALITY}" >> "${GITHUB_ENV}"
fi
