#!/usr/bin/env bash
set -euo pipefail

TMP_PACKAGE_PATH=${1}

export DEBIAN_FRONTEND=noninteractive
apt-get update --fix-missing -q
apt-get dist-upgrade --fix-missing -y

echo "Install default packages"
apt-get install -y $(paste -s -d ' ' ${TMP_PACKAGE_PATH}packages_default)

# Detect version
. /etc/os-release
VERSION_ID=${VERSION_ID:-}
VERSION_MAJOR=${VERSION_ID%%.*}

if [[ -n ${VERSION_ID} && -f ${TMP_PACKAGE_PATH}packages_${VERSION_ID} ]]; then
  echo "Install packages for version ${VERSION_ID}"
  apt-get install -y $(paste -s -d ' ' ${TMP_PACKAGE_PATH}packages_${VERSION_ID})
elif [[ ${VERSION_MAJOR} =~ ^[0-9]+$ ]] && (( VERSION_MAJOR < 10 )); then
  echo "No specified packages for version ${VERSION_ID} using default packages for version lower than 10"
  apt-get install -y $(paste -s -d ' ' ${TMP_PACKAGE_PATH}packages_lower_10)
else
  echo "No specified packages for version ${VERSION_ID} using default packages for version higher than 10"
  apt-get install -y $(paste -s -d ' ' ${TMP_PACKAGE_PATH}packages_higher_10)
fi
