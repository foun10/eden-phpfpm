#!/usr/bin/env bash
app_dir=${APP_DIR}

if [[ ! -f "${app_dir}/init.lock" ]]; then
    touch "${app_dir}/init.lock"
    chmod 777 "${app_dir}/init.lock"

    if [[ -f "${app_dir}/eden-phpfpm/init.sh" ]]; then
        bash "${app_dir}/eden-phpfpm/init.sh"
    fi
fi

if [[ -f "${app_dir}/eden-phpfpm/always.sh" ]]; then
    bash "${app_dir}/eden-phpfpm/always.sh"
fi

# Start php
echo "start php"
php-fpm