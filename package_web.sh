#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

if [[ "${CI_BUILD}" == "no" ]]; then
  exit 1
fi

APP_NAME_LC="$( echo "${APP_NAME}" | awk '{print tolower($0)}' )"

mkdir -p assets

tar -xzf ./vscode.tar.gz

cd vscode || { echo "'vscode' dir not found"; exit 1; }

NODE_VERSION="20.18.1"

export VSCODE_PLATFORM='linux'
export VSCODE_SKIP_NODE_VERSION_CHECK=1

VSCODE_HOST_MOUNT="$( pwd )"

export VSCODE_HOST_MOUNT

sed -i "/target/s/\"20.*\"/\"${NODE_VERSION}\"/" remote/.npmrc

for i in {1..5}; do # try 5 times
  npm ci --prefix build && break
  if [[ $i == 3 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."
done

for i in {1..5}; do # try 5 times
  npm ci && break
  if [[ $i == 3 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."
done

if [[ "${SHOULD_BUILD_WEB_ONLY}" != "no" ]]; then
  echo "Building WEB Only"
  yarn gulp vscode-web-only

  pushd "../vscode-web-only"

  echo "Archiving WEB Only"
  tar czf "../assets/${APP_NAME_LC}-web-only-${RELEASE_VERSION}.tar.gz" .

  popd
fi

if [[ "${SHOULD_BUILD_WEB}" != "no" ]]; then
  echo "Building WEB"
  yarn gulp vscode-web
  # yarn gulp minify-vscode-web
  # yarn gulp "vscode-web-min-ci"

  pushd "../vscode-web"

  echo "Archiving WEB"
  tar czf "../assets/${APP_NAME_LC}-web-${RELEASE_VERSION}.tar.gz" .

  popd
fi

cd ..

npm install -g checksum

sum_file() {
  if [[ -f "${1}" ]]; then
    echo "Calculating checksum for ${1}"
    checksum -a sha256 "${1}" > "${1}".sha256
    checksum "${1}" > "${1}".sha1
  fi
}

cd assets

for FILE in *; do
  if [[ -f "${FILE}" ]]; then
    sum_file "${FILE}"
  fi
done

cd ..
