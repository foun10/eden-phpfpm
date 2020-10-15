EDEN - PHPFPM
=============

General information
-------------------

This container provides php 5.6, 7.0, 7.1, 7.2 and 7.3 trough php fpm and is part of the eden project by foun10.

Environment variables
---------------------

Name | Description | possible values (/format) | default | mandatory
--- | --- | --- | --- | ---
APP_DIR | The app directory. | any valid dir | /var/www/app | n
HTDOCS_DIR | The htdocs directory. | any valid dir | same as APP_DIR | n
DB_HOST | The database host. | any valid host | mysql | n
DB_USER | The database username. | any valid username | root | n
DB_PASS | The database password. | any valid password | root | n
DB_NAME | The database name. | any valid db name | app | n
DB_DUMP | The dump file or directory from which you want to import the queries on the first run. | any valid path or file | EMPTY | n
BACKUP_URL | The url from which you want to grab the backup. | any valid url | EMPTY | n
BACKUP_USER | The username for the backup download. | any valid username | EMPTY | n
BACKUP_PASS | The password for the backup download. | any valid password | EMPTY | n
PROJECT_URL | The project url for the config files. If you use docker dns something like _FOLDERNAME__web_1.local.docker | any valid url | EMPTY | n
PROJECT_TYPE | Depending on the project type the script available at https://github.com/foun10/eden-phpfpm-project-types will be executed. | any valid project type | EMPTY | n
USER_MAIL | The user mail for the default user. | any valid mail | dev@local.docker | n
USER_PASS | The password for the default user. | any valid password | root | n
FILE_PERMISSIONS | If set the file permission of the files under APP_DIR will be changed to the defined permission. | any valid permission mode | EMPTY | n
CUSTOM_UID | If set the uid for the files under APP_DIR will be changed to the defined uid. Use _default_ for the default container uid | any valid uid | EMPTY | n
UPDATE_GITIGNORE | If set to _y_ the gitignore file will automatically updated. | y or n | n | n


Additional commands
-------------------

There are three possible hooks to execute additional commands at the startup. Place a file under `APP_DIR/eden-phpfpm/TYPE.sh`. Valid types are `pre`, `post` and `always.`


First run
---------

- After the first run a file with the name _init.lock_ will be created. Remove it to rerun the setup script again.
- If a db dump file or path is provided the run script will run the queries.
    - If a directory is provided the query are executed in alphabetical order. It's suggested to name the files with an numbered prefix like 000_dump.sql.
- If a backup url is provided the backup will be downloaded and extracted at the app dir
    - The backup file must be .tar.gz zipped.
    - **WARNING: ALL FILES WHICH ARE NOT UNDER VERSION CONTROL WILL BE DELETED BEFORE THE BACKUP WILL BE EXTRACTED**
