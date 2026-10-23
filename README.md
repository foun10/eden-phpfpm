EDEN - PHPFPM
=============

[![CI](https://github.com/foun10/eden-phpfpm/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/foun10/eden-phpfpm/actions/workflows/ci.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/foun10/eden-phpfpm?logo=docker&logoColor=white)](https://hub.docker.com/r/foun10/eden-phpfpm)
[![Image Size](https://img.shields.io/docker/image-size/foun10/eden-phpfpm/latest?label=image%20size&logo=docker&logoColor=white)](https://hub.docker.com/r/foun10/eden-phpfpm/tags)
[![PHP](https://img.shields.io/badge/PHP-7.3%20%E2%80%93%208.5-777BB4?logo=php&logoColor=white)](#tags)
[![Platforms](https://img.shields.io/badge/platforms-amd64%20%7C%20arm64-2496ED?logo=linux&logoColor=white)](#tags)
[![Xdebug](https://img.shields.io/badge/Xdebug-included-3D8B37)](#xdebug)
[![Node.js](https://img.shields.io/badge/Node.js-18-5FA04E?logo=nodedotjs&logoColor=white)](#nodejs)

PHP-FPM development images for the **eden** project by foun10. Each image is a ready-to-use PHP runtime: common extensions, Xdebug, Composer, Node.js and a MySQL client, plus startup hooks for project-specific setup.

```sh
docker pull foun10/eden-phpfpm:8.5
```

Tags
----

All tags are built for `linux/amd64` and `linux/arm64` from the official `php:<version>-fpm` images.

| Tag                 | PHP |
|---------------------|-----|
| `8.5`               | 8.5 |
| `8.4`, **`latest`** | 8.4 |
| `8.3`               | 8.3 |
| `8.2`               | 8.2 |
| `8.1`               | 8.1 |
| `8.0`               | 8.0 |
| `7.4`               | 7.4 |
| `7.3`               | 7.3 |

Pin a version tag in your project. `latest` moves when a new default PHP version is chosen.

What's inside
-------------

| Component      | Details |
|----------------|---------|
| PHP extensions | amqp, bcmath, curl, ftp, gd, iconv, intl, mbstring, mcrypt, mysqli, oauth, pdo, pdo_mysql, pgsql, soap, xdebug, yaml, zip (plus everything compiled into the base image, e.g. OPcache) |
| Best effort    | ionCube Loader and xsd are installed where the PHP version supports them. The build doesn't fail if they're unavailable. |
| Composer       | latest 2.x |
| Node.js        | 18, installed with nvm |
| CLI tools      | git, curl, wget, vim, gnupg, MySQL/MariaDB client |

PHP-FPM listens on port **9000**. Put a web server in front of it, such as `foun10/eden-apache-phpfpm`, which proxies to `php:9000`.

Usage
-----

Example `docker-compose.yml` service:

```yaml
services:
  php:
    image: foun10/eden-phpfpm:8.5
    volumes:
      - ./:/var/www/html
      - ./docker/eden-scripts:/eden-scripts   # optional startup hooks
    environment:
      PHP_DISPLAY_ERRORS: "1"
      XDEBUG_MODE: debug                      # Xdebug is off by default
```

Configuration
-------------

Everything is configured through environment variables, read when PHP starts.

### General

| Name      | Description                             | Default         |
|-----------|-----------------------------------------|-----------------|
| `APP_DIR` | Working directory of the container.     | `/var/www/html` |

### PHP

| Name                         | php.ini setting          | Default |
|------------------------------|--------------------------|---------|
| `PHP_MEMORY_LIMIT`           | `memory_limit`           | `-1` (unlimited) |
| `PHP_MAX_EXECUTION_TIME`     | `max_execution_time`     | `-1` (unlimited) |
| `PHP_POST_MAX_SIZE`          | `post_max_size`          | `100M`  |
| `PHP_UPLOAD_MAX_FILESIZE`    | `upload_max_filesize`    | `100M`  |
| `PHP_ERROR_REPORTING`        | `error_reporting`        | `E_ALL` |
| `PHP_DISPLAY_ERRORS`         | `display_errors`         | *not set* (empty, so errors aren't displayed) |
| `PHP_DISPLAY_STARTUP_ERRORS` | `display_startup_errors` | `1`     |

### Xdebug

Xdebug is installed but **off** by default. Set `XDEBUG_MODE` to enable it, for example `debug`, `develop,debug` or `coverage`.

| Name                        | Xdebug setting               | Default                |
|-----------------------------|------------------------------|------------------------|
| `XDEBUG_MODE`               | `xdebug.mode`                | `off`                  |
| `XDEBUG_START_WITH_REQUEST` | `xdebug.start_with_request`  | `no`                   |
| `XDEBUG_CLIENT_HOST`        | `xdebug.client_host`         | `host.docker.internal` |
| `XDEBUG_CLIENT_PORT`        | `xdebug.client_port`         | `9003`                 |
| `XDEBUG_IDE_KEY`            | `xdebug.idekey`              | `docker`               |
| `XDEBUG_LOG`                | `xdebug.log`                 | `/dev/stdout`          |
| `XDEBUG_LOG_LEVEL`          | `xdebug.log_level`           | `0`                    |
| `XDEBUG_MAX_NESTING_LEVEL`  | `xdebug.max_nesting_level`   | `1024`                 |

Startup hooks
-------------

Mount a directory at `/eden-scripts` to run your own commands when the container starts, before PHP-FPM:

| Script      | When it runs |
|-------------|--------------|
| `init.sh`   | Once, on the first start. Afterwards `init.lock` is created in `/eden-scripts`. |
| `always.sh` | On every start, after `init.sh`. |

To run `init.sh` again, delete `/eden-scripts/init.lock` and restart the container. The directory must be writable so the lock file can be created.

Both scripts run as root with `bash`. If either one fails, the container stops, so make sure they exit with 0.

Node.js
-------

Node is managed by nvm in `/root/.nvm`. Interactive shells (`docker exec -it <container> bash`) have `node` and `npm` on the `PATH`. Non-interactive commands, including the startup hooks, need to load nvm first:

```sh
source "$NVM_DIR/nvm.sh"
npm ci
```

Building locally
----------------

The base image is selected with the `SOURCE_TAG` build argument:

```sh
docker build --build-arg SOURCE_TAG=php:8.5-fpm -t foun10/eden-phpfpm:8.5 .
docker run --rm foun10/eden-phpfpm:8.5 php -m
```

Every push to `master` builds all versions in the GitHub Actions matrix (`.github/workflows/ci.yml`) and publishes them to Docker Hub. To add a PHP version, add a matrix entry there and to the tag table above.
