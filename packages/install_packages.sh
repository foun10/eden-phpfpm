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

if [[ -f ${TMP_PACKAGE_PATH}packages_${VERSION_ID} ]]; then
  echo "Install packages for version ${VERSION_ID}"
  apt-get install -y $(paste -s -d ' ' ${TMP_PACKAGE_PATH}packages_${VERSION_ID})
else
  echo "No specified packages for version ${VERSION_ID} found using fallback packages"
  apt-get install -y $(paste -s -d ' ' ${TMP_PACKAGE_PATH}packages_fallback)
fi