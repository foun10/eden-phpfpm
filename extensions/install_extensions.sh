#!/usr/bin/env bash
set -euo pipefail

TMP_PHP_EXTENSIONS_PATH=${1}

if [[ -z "${2+x}" ]]; then
    PHP_EXTENSIONS_PATH="/usr/local/lib/php/extensions/"
else
    PHP_EXTENSIONS_PATH=${2}
fi

if [[ -z "${3+x}" ]]; then
    PHP_INI_PATH="/usr/local/etc/php/conf.d/"
else
    PHP_INI_PATH=${3}
fi

install_extension() {
    local extension=${1}
    local use_full_path=${2+x}
    local extension_name=''
    local source_path=''
    local file_regex="(^.*\/)(.*)-[0-9]\.[0-9]\.so"

    if [[ ${extension} =~ ${file_regex} ]]; then
        if [[ -f ${extension} ]]; then
            source_path=${BASH_REMATCH[1]}
            extension_name=${BASH_REMATCH[2]}

            local module_file="${source_path}${extension_name}.so"
            mv ${extension} ${module_file}
            mv ${module_file} ${PHP_EXTENSIONS_PATH}*
        else
            echo "${extension} doesn't exist. skipping"
            return
        fi
    else
        source_path=${TMP_PHP_EXTENSIONS_PATH}
        extension_name=${extension}
    fi

    local extension_dir=$(ls ${PHP_EXTENSIONS_PATH})
    local extension_name_with_path="${PHP_EXTENSIONS_PATH}${extension_dir}/${extension_name}.so"

    if [[ -f ${extension_name_with_path} ]]; then
        docker-php-ext-enable ${extension_name}
    else
        docker-php-ext-install ${extension_name}
    fi

    local ini_file="${source_path}${extension_name}.ini"

    if [[ -f ${ini_file} ]]; then
        local original_ini_name=docker-php-ext-${extension_name}.ini
        local original_ini_file=${PHP_INI_PATH}${original_ini_name}

        if [[ -f ${original_ini_file} ]]; then
            if ! $(grep -q 'zend_extension' ${original_ini_file}); then
                sed -i -e 's/extension/zend_extension/g' ${original_ini_file}
            fi

            if [[ ${use_full_path} ]] && $(grep -q "zend_extension=${extension_name}.so" ${original_ini_file}); then
                sed -i -e "s|${extension_name}.so|${extension_name_with_path}|g" ${original_ini_file}
            fi

            cat ${ini_file} >> ${original_ini_file}
        else
            mv ${ini_file} ${original_ini_file}
        fi
    fi
}

PHP_VERSION=$(php --version | grep -Po "(?<=PHP )([0-9]|\.)*(?=\s|$)")
VERSION_REGEX="^([0-9]+)\.([0-9]+)\.([0-9]+).*"

if [[ ${PHP_VERSION} =~ ${VERSION_REGEX} ]]; then
    SHORTEN_PHP_VERSION="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"

    install_extension iconv

    if [[ ${PHP_VERSION} =~ ^5\.([0-9]+).* ]] || [[ ${PHP_VERSION} =~ ^7\.([0-1]+).* ]]; then
        install_extension mcrypt
    fi

    if [[ ${PHP_VERSION} =~ ^5\.([0-3]+).* ]]; then
        mkdir /usr/include/freetype2/freetype
        ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h
    fi

    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
    install_extension gd
    install_extension curl
    install_extension mysqli

    if [[ ${PHP_VERSION} =~ ^5\.([0-9]+).* ]]; then
        install_extension mysql
    fi

    install_extension pdo
    install_extension pdo_mysql
    install_extension pgsql

    docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
    install_extension pdo_pgsql

    install_extension mbstring
    install_extension zip
    install_extension soap
    install_extension intl
    install_extension bcmath

    if [[ ${PHP_VERSION} =~ ^5\.([0-9]+).* ]]; then
        pecl install yaml-1.3.2
    else
        pecl install yaml
    fi

    install_extension yaml

    if [[ ${PHP_VERSION} =~ ^5\.([0-3]+).* ]]; then
        pecl install xdebug-2.2.7
    elif [[ ${PHP_VERSION} =~ ^5\.([4-9]+).* ]]; then
        pecl install xdebug-2.4.1
    else
        pecl install xdebug
    fi

    install_extension xdebug

    install_extension "${TMP_PHP_EXTENSIONS_PATH}ioncube-${SHORTEN_PHP_VERSION}.so"

    if [[ ${PHP_VERSION} =~ ^5\.([0-3]+).* ]]; then
        install_extension "${TMP_PHP_EXTENSIONS_PATH}zendguardloader-${SHORTEN_PHP_VERSION}.so" true
    else
        install_extension "${TMP_PHP_EXTENSIONS_PATH}zendguardloader-${SHORTEN_PHP_VERSION}.so"
    fi

    if [[ ${PHP_VERSION} =~ ^5\.([0-9]+).* ]]; then
        pecl install oauth-1.2.3
    else
        pecl install oauth
    fi

    mv "${TMP_PHP_EXTENSIONS_PATH}oauth.ini" "${PHP_INI_PATH}oauth.ini"
fi