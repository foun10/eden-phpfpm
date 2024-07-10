EDEN - PHPFPM
=============

General information
-------------------

This container provides php 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1 and 8.2 trough php fpm and is part of the eden project by foun10.

Environment variables
---------------------

| Name    | Description        | possible values (/format) | default       | mandatory |
|---------|--------------------|---------------------------|---------------|-----------|
| APP_DIR | The app directory. | any valid dir             | /var/www/html | n         |

Additional commands
-------------------

There are two possible hooks to execute additional commands at the startup. Mount the scripts under `/eden-scripts`. Valid types are `init` and `always.`

| Name      | Description                                 |
|-----------|---------------------------------------------|
| init.sh   | Runs if the `inti.lock` file isn't present. |
| always.sh | Runs every time if the container starts.    |

First run
---------

- After the first run a file with the name _init.lock_ will be created. Remove it to rerun the setup script again.