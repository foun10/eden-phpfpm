#!/usr/bin/env bash
set -euo pipefail

if [[ -d "/eden-scripts" ]]; then
  if [[ ! -f "/eden-scripts/init.lock" ]]; then
    if [[ -f "/eden-scripts/init.sh" ]]; then
      bash "/eden-scripts/init.sh"
    fi

    touch "/eden-scripts/init.lock"
    chmod 777 "/eden-scripts/init.lock"
  fi
fi

if [[ -f "/eden-scripts/always.sh" ]]; then
  bash "/eden-scripts/always.sh"
fi

# Start php
echo "start php"
php-fpm