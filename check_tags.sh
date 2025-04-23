#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

if [[ -z "${GH_TOKEN}" ]] && [[ -z "${GITHUB_TOKEN}" ]] && [[ -z "${GH_ENTERPRISE_TOKEN}" ]] && [[ -z "${GITHUB_ENTERPRISE_TOKEN}" ]]; then
  echo "Will not build because no GITHUB_TOKEN defined"
  exit 0
else
  GITHUB_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-${GH_ENTERPRISE_TOKEN:-${GITHUB_ENTERPRISE_TOKEN}}}}"
fi

# Support for GitHub Enterprise
GH_HOST="${GH_HOST:-github.com}"

APP_NAME_LC="$( echo "${APP_NAME}" | awk '{print tolower($0)}' )"

GITHUB_RESPONSE=$( curl -s -H "Authorization: token ${GITHUB_TOKEN}" "https://api.${GH_HOST}/repos/${ASSETS_REPOSITORY}/releases/latest" )
LATEST_VERSION=$( echo "${GITHUB_RESPONSE}" | jq -c -r '.tag_name' )
date=$( env TZ=Asia/Taipei date +%y%j )

if [[ "${LATEST_VERSION}" =~ ^([0-9]+\.[0-9]+\.[0-9]+) ]]; then
  if [[ "${MS_TAG}" != "${BASH_REMATCH[1]}" ]]; then
    echo "New VSCode version, new build"
  elif [[ "${NEW_RELEASE}" == "true" ]]; then
    echo "New release build"
  elif [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    BODY=$( echo "${GITHUB_RESPONSE}" | jq -c -r '.body' )

    if [[ "${BODY}" =~ \[([a-z0-9]+)\] ]]; then
      if [[ "${MS_COMMIT}" != "${BASH_REMATCH[1]}" ]]; then
        echo "New VSCode Insiders version, new build"
      fi
    fi
  fi

  echo "Switch to release version: ${RELEASE_VERSION}"

  ASSETS=$( echo "${GITHUB_RESPONSE}" | jq -c '.assets | map(.name)?' )
else
  echo "can't check assets"
  exit 1
fi

contains() {
  # add " to match the end of a string so any hashs won't be matched by mistake
  echo "${ASSETS}" | grep "${1}\""
}

# macos
if [[ "${OS_NAME}" == "osx" ]]; then
  if [[ -z $( contains "${APP_NAME}-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ) ]]; then
    echo "Building on MacOS because we have no ZIP"
  fi

  if [[ -z $( contains ".${VSCODE_ARCH}.${RELEASE_VERSION}.dmg" ) ]]; then
    echo "Building on MacOS because we have no DMG"
  fi

  if [[ -z $( contains "${APP_NAME_LC}-reh-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
    echo "Building on MacOS because we have no REH archive"
  fi

  if [[ -z $( contains "${APP_NAME_LC}-reh-web-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
    echo "Building on MacOS because we have no REH-web archive"
  fi

  echo "Already have all the MacOS builds"
elif [[ "${OS_NAME}" == "windows" ]]; then

  # windows-arm64
  if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
    if [[ -z $( contains "${APP_NAME}Setup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
      echo "Building on Windows arm64 because we have no system setup"
    fi

    if [[ -z $( contains "UserSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
      echo "Building on Windows arm64 because we have no user setup"
    fi

    if [[ -z $( contains "${APP_NAME}-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ) ]]; then
      echo "Building on Windows arm64 because we have no zip"
    fi

    echo "Already have all the Windows arm64 builds"

  # windows-ia32
  elif [[ "${VSCODE_ARCH}" == "ia32" ]]; then
    if [[ -z $( contains "${APP_NAME}Setup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
      echo "Building on Windows ia32 because we have no system setup"
    fi

    if [[ -z $( contains "UserSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
      echo "Building on Windows ia32 because we have no user setup"
    fi

    if [[ -z $( contains "${APP_NAME}-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ) ]]; then
      echo "Building on Windows ia32 because we have no zip"
    fi

    if [[ -z $( contains "${APP_NAME}-${VSCODE_ARCH}-${RELEASE_VERSION}.msi" ) ]]; then
      echo "Building on Windows ia32 because we have no msi"
    fi

    if [[ -z $( contains "${APP_NAME}-${VSCODE_ARCH}-updates-disabled-${RELEASE_VERSION}.msi" ) ]]; then
      echo "Building on Windows ia32 because we have no updates-disabled msi"
    fi

    if [[ -z $( contains "${APP_NAME_LC}-reh-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Windows ia32 because we have no REH archive"
    fi

    if [[ -z $( contains "${APP_NAME_LC}-reh-web-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Windows ia32 because we have no REH-web archive"
    fi

    echo "Already have all the Windows ia32 builds"

  # windows-x64
  else
    if [[ -z $( contains "${APP_NAME}Setup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
      echo "Building on Windows x64 because we have no system setup"
    fi

    if [[ -z $( contains "UserSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
      echo "Building on Windows x64 because we have no user setup"
    fi

    if [[ -z $( contains "${APP_NAME}-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ) ]]; then
      echo "Building on Windows x64 because we have no zip"
    fi

    if [[ -z $( contains "${APP_NAME}-${VSCODE_ARCH}-${RELEASE_VERSION}.msi" ) ]]; then
      echo "Building on Windows x64 because we have no msi"
    fi

    if [[ -z $( contains "${APP_NAME}-${VSCODE_ARCH}-updates-disabled-${RELEASE_VERSION}.msi" ) ]]; then
      echo "Building on Windows x64 because we have no updates-disabled msi"
    fi

    if [[ -z $( contains "${APP_NAME_LC}-reh-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Windows x64 because we have no REH archive"
    fi

    if [[ -z $( contains "${APP_NAME_LC}-reh-web-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Windows x64 because we have no REH-web archive"
    fi

    echo "Already have all the Windows x64 builds"
  fi
else
  if [[ "${OS_NAME}" == "linux" ]]; then
    if [[ "${CHECK_ONLY_REH}" == "yes" ]]; then

      if [[ -z $( contains "${APP_NAME_LC}-reh-linux-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux ${VSCODE_ARCH} because we have no REH archive"
      else
        echo "Already have the Linux REH ${VSCODE_ARCH} archive"
      fi

      if [[ -z $( contains "${APP_NAME_LC}-reh-web-linux-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux ${VSCODE_ARCH} because we have no REH-web archive"
      else
        echo "Already have the Linux REH-web ${VSCODE_ARCH} archive"
      fi

    else

      # linux-arm64
      if [[ "${VSCODE_ARCH}" == "arm64" || "${CHECK_ALL}" == "yes" ]]; then
        if [[ -z $( contains "arm64.deb" ) ]]; then
          echo "Building on Linux arm64 because we have no DEB"
        fi

        if [[ -z $( contains "aarch64.rpm" ) ]]; then
          echo "Building on Linux arm64 because we have no RPM"
        fi

        if [[ -z $( contains "${APP_NAME}-linux-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux arm64 because we have no TAR"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-linux-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux arm64 because we have no REH archive"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-web-linux-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux arm64 because we have no REH-web archive"
        fi

        echo "Already have all the Linux arm64 builds"
      fi

      # linux-armhf
      if [[ "${VSCODE_ARCH}" == "armhf" || "${CHECK_ALL}" == "yes" ]]; then
        if [[ -z $( contains "armhf.deb" ) ]]; then
          echo "Building on Linux arm because we have no DEB"
        fi

        if [[ -z $( contains "armv7hl.rpm" ) ]]; then
          echo "Building on Linux arm because we have no RPM"
        fi

        if [[ -z $( contains "${APP_NAME}-linux-armhf-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux arm because we have no TAR"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-linux-armhf-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux arm because we have no REH archive"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-web-linux-armhf-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux arm because we have no REH-web archive"
        fi

        echo "Already have all the Linux arm builds"
      fi

      # linux-ppc64le
      if [[ "${VSCODE_ARCH}" == "ppc64le" || "${CHECK_ALL}" == "yes" ]]; then
        if [[ -z $( contains "${APP_NAME}-linux-ppc64le-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux PowerPC64LE because we have no TAR"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-linux-ppc64le-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux PowerPC64LE because we have no REH archive"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-web-linux-ppc64le-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux PowerPC64LE because we have no REH-web archive"
        fi

        echo "Already have all the Linux PowerPC64LE builds"
      fi

      # linux-riscv64
      if [[ "${VSCODE_ARCH}" == "riscv64" || "${CHECK_ALL}" == "yes" ]]; then
        if [[ -z $( contains "${APP_NAME}-linux-riscv64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux RISC-V 64 because we have no TAR"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-linux-riscv64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux RISC-V 64 because we have no REH archive"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-web-linux-riscv64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux RISC-V 64 because we have no REH-web archive"
        fi

        echo "Already have all the Linux riscv64 builds"
      fi

      # linux-loong64
      if [[ "${VSCODE_ARCH}" == "loong64" || "${CHECK_ALL}" == "yes" ]]; then
        if [[ -z $( contains "${APP_NAME}-linux-loong64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux Loong64 because we have no TAR"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-linux-loong64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux Loong64 because we have no REH archive"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-web-linux-loong64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux Loong64 because we have no REH-web archive"
        fi

        echo "Already have all the Linux Loong64 builds"
      fi

      # linux-s390x
      if [[ "${VSCODE_ARCH}" == "s390x" || "${CHECK_ALL}" == "yes" ]]; then
        if [[ -z $( contains "${APP_NAME_LC}-reh-linux-s390x-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux s390x because we have no REH archive"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-web-linux-s390x-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux s390x because we have no REH-web archive"
        fi

        echo "Already have all the Linux s390x builds"
      fi

      # linux-x64
      if [[ "${VSCODE_ARCH}" == "x64" || "${CHECK_ALL}" == "yes" ]]; then
        if [[ -z $( contains "amd64.deb" ) ]]; then
          echo "Building on Linux x64 because we have no DEB"
        fi

        if [[ -z $( contains "x86_64.rpm" ) ]]; then
          echo "Building on Linux x64 because we have no RPM"
        fi

        if [[ -z $( contains "${APP_NAME}-linux-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux x64 because we have no TAR"
        fi

        if [[ -z $( contains "x86_64.AppImage" ) ]]; then
          echo "Building on Linux x64 because we have no AppImage"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-linux-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux x64 because we have no REH archive"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-web-linux-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux x64 because we have no REH-web archive"
        fi

        echo "Already have all the Linux x64 builds"
      fi
    fi
  fi

  if [[ "${OS_NAME}" == "alpine" ]] || [[ "${OS_NAME}" == "linux" && "${CHECK_ALL}" == "yes" ]]; then

    if [[ "${CHECK_ONLY_REH}" == "yes" ]]; then
      if [[ -z $( contains "${APP_NAME_LC}-reh-alpine-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Alpine ${VSCODE_ARCH} because we have no REH archive"
      else
        echo "Already have the Alpine REH ${VSCODE_ARCH} archive"
      fi

      if [[ -z $( contains "${APP_NAME_LC}-reh-web-alpine-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Alpine ${VSCODE_ARCH} because we have no REH-web archive"
      else
        echo "Already have the Alpine REH-web ${VSCODE_ARCH} archive"
      fi
    else

      # alpine-arm64
      if [[ "${VSCODE_ARCH}" == "arm64" || "${CHECK_ALL}" == "yes" ]]; then
        if [[ -z $( contains "${APP_NAME_LC}-reh-alpine-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Alpine arm64 because we have no REH archive"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-web-alpine-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Alpine arm64 because we have no REH-web archive"
        fi
      fi

      # alpine-x64
      if [[ "${VSCODE_ARCH}" == "x64" || "${CHECK_ALL}" == "yes" ]]; then
        if [[ -z $( contains "${APP_NAME_LC}-reh-alpine-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Alpine x64 because we have no REH archive"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-web-alpine-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Alpine x64 because we have no REH-web archive"
        fi
      fi
    fi
  fi
fi

echo "Release assets do not exist at all, continuing build"
