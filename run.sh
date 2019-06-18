#!/usr/bin/env bash
app_dir=${APP_DIR}
htdocs_dir=${HTDOCS_DIR}
db_host=${DB_HOST}
db_user=${DB_USER}
db_pass=${DB_PASS}
db_name=${DB_NAME}
db_dump=${DB_DUMP}
backup_url=${BACKUP_URL}
backup_user=${BACKUP_USER}
backup_pass=${BACKUP_PASS}
project_url=${PROJECT_URL}
project_type=${PROJECT_TYPE}
user_mail=${USER_MAIL}
user_pass=${USER_PASS}
file_permissions=${FILE_PERMISSIONS}

if [[ ${htdocs_dir} = '' ]]; then
    htdocs_dir=${app_dir}
fi

function import_sql() {
    local sql_file=${1}

    echo "Import ${sql_file}"
    mysql -h ${db_host} -u ${db_user} -p${db_pass} --max_allowed_packet=1073741824 -f ${db_name} < ${sql_file}
    echo "Import of ${sql_file} done!"
}

if [[ ! -f "${app_dir}/init.lock" ]]; then
    if [[ -f "${app_dir}/eden-phpfpm/pre.sh" ]]; then
        bash "${app_dir}/eden-phpfpm/pre.sh"
    fi

    cd ${app_dir}

    # Check for the backup and download it if it doesn't exist
    backup_file="${app_dir}/backup.tar.gz"

    if [[ ${backup_url} != '' ]] && [[ ! -f "${backup_file}" ]]; then
        echo "downloading backup"
        params=""

        if [[ ${backup_user} != '' ]]; then
            params+="--user=${backup_user} "

            if [[ ${backup_pass} != '' ]]; then
                params+="--password=${backup_pass}"
            fi
        fi

        wget -q --no-check-certificate ${params} ${backup_url} -O ${backup_file}

        if [[ ! -f "${backup_file}" ]]; then
            echo "Backup file not found!"
        else
            git clean -dfx --exclude=backup.tar.gz --exclude=.idea # Remove all files expect the files under version control
            echo "extracting backup"
            tar xfvzk "${backup_file}" >/dev/null 2>&1
        fi
    fi

    # Import the database
    if [[ ${db_dump} != '' ]]; then
        db_dump_with_path="${app_dir}/${db_dump}"

        if [[ -f "${db_dump_with_path}" ]] || [[ -d "${db_dump_with_path}" ]]; then
            echo "waiting for mysql service"
            while ! mysqladmin ping -h"${db_host}" --silent; do
                sleep 1
            done

            echo "clean up database"
            mysql -h ${db_host} -u ${db_user} -p${db_pass} -e "DROP DATABASE IF EXISTS ${db_name};"
            mysql -h ${db_host} -u ${db_user} -p${db_pass} -e "CREATE DATABASE ${db_name};"

            if [[ -f "${db_dump_with_path}" ]]; then
                import_sql "${db_dump_with_path}"
            elif [[ -d "${db_dump_with_path}" ]]; then
                # Unzip files
                for file in ${db_dump_with_path}/*.bz2; do
                    if [[ -f "${file}" ]]; then
                        bzip2 -dk "${file}"
                    fi
                done

                for file in ${db_dump_with_path}/*.sql; do
                    if [[ -f "${file}" ]]; then
                        import_sql "${file}"
                    fi
                done
            fi
        fi
    fi

    project_type_url="https://raw.githubusercontent.com/foun10/eden-phpfpm-project-types/master/types/${project_type}.sh"

    if [[ `wget -S --spider ${project_type_url} 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
        project_type_file="/tmp/project.sh"
        wget -q --no-check-certificate ${project_type_url} -O ${project_type_file}
        source ${project_type_file}
    else
        echo "Project type ${project_type} not found, please see https://github.com/foun10/eden-phpfpm-project-types for more information."
    fi

    if [[ ${file_permissions} != '' ]]; then
        echo "set file permissions"
        chmod ${file_permissions} -R ${app_dir}
    fi

    chown $UID -R ${app_dir}

    echo "clean up"
    if [[ -f "${backup_file}" ]]; then
        rm -f "${backup_file}"
    fi

    touch "${app_dir}/init.lock"
    chmod 777 "${app_dir}/init.lock"

    if [[ -f "${app_dir}/.gitignore" ]]; then
        echo "" >> "${app_dir}/.gitignore" # new line
        echo "$(git status --porcelain | grep '^??' | cut -c4-)" >> "${app_dir}/.gitignore"
    else
        echo "$(git status --porcelain | grep '^??' | cut -c4-)" > "${app_dir}/.gitignore"
    fi

    if [[ -f "${app_dir}/eden-phpfpm/post.sh" ]]; then
        bash "${app_dir}/eden-phpfpm/post.sh"
    fi
fi

if [[ -f "${app_dir}/eden-phpfpm/always.sh" ]]; then
    bash "${app_dir}/eden-phpfpm/always.sh"
fi

# Start php
echo "start php"
php-fpm