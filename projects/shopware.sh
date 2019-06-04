#!/usr/bin/env bash
mysql -h ${db_host} -u ${db_user} -p${db_pass} ${db_name} -e "UPDATE s_core_shops SET base_path=NULL, base_url=NULL,hosts='${project_url}',host='${project_url}', secure=0, always_secure=0 WHERE s_core_shops.default=1;"
mysql -h ${db_host} -u ${db_user} -p${db_pass} ${db_name} -e "INSERT s_core_auth (roleID, localeID, username, name, email, encoder, password, failedlogins, active, lockeduntil) VALUES (1, 1, '${user_mail}', 'admin', '${user_mail}', 'md5', MD5('${user_pass}'), 0, 1, '0001-01-01 00:00:00');"

echo "create config.php"
cat <<EOF > config.php
<?php return array(
    'db' =>
        array(
            'username' => '${db_user}',
            'password' => '${db_pass}',
            'host' => '${db_host}',
            'port' => '3306',
            'dbname' => '${db_name}',
        ),
    'front' => array(
        'noErrorHandler' => true,
        'throwExceptions' => true,
        'useDefaultControllerAlways' => true,
        'disableOutputBuffering' => true,
        'showException' => true,
    ),
    'template' => array(
        'forceCompile' => true,
    )
);
EOF

if [[ -f "${app_dir}/cache/clear_cache.sh" ]]; then
    echo "clearing caches!"
    chmod 777 "${app_dir}/cache/clear_cache.sh"
    "${app_dir}/cache/clear_cache.sh"
    chmod -R 777 "${app_dir}/cache"
elif [[ -f "${app_dir}/var/cache/clear_cache.sh" ]]; then
    echo "clearing caches!"
    chmod 777 ${app_dir}/var/cache/clear_cache.sh
    "${app_dir}/var/cache/clear_cache.sh"
    chmod -R 777 "${app_dir}/var"
fi

if [[ ! -f "${app_dir}/index.php" ]]; then
    echo "create index.php"
    cat <<EOF > index.php
<?php
include 'shopware.php';
EOF
fi

echo "Add media dirs"
rm -rf ${app_dir}media
mkdir -p ${app_dir}media
mkdir -p ${app_dir}media/archive
mkdir -p ${app_dir}media/image
mkdir -p ${app_dir}media/image/thumbnail
mkdir -p ${app_dir}media/music
mkdir -p ${app_dir}media/pdf
mkdir -p ${app_dir}media/temp
mkdir -p ${app_dir}media/unkown
mkdir -p ${app_dir}media/video