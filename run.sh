#!/usr/bin/env bash
if [[ ! -f "/eden-scripts/init.lock" ]]; then
    touch "/eden-scripts/init.lock"
    chmod 777 "/eden-scripts/init.lock"

    if [[ -f "/eden-scripts/init.sh" ]]; then
        bash "/eden-scripts/init.sh"
    fi
fi

if [[ -f "/eden-scripts/always.sh" ]]; then
    bash "/eden-scripts/always.sh"
fi

# Start php
echo "start php"
php-fpm