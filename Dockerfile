ARG SOURCE_TAG=php:fpm
FROM ${SOURCE_TAG}
MAINTAINER Alexander Schneider <schneider@foun10.com>

# Install packages
ADD packages /tmp/packages
RUN chmod +x /tmp/packages/install_packages.sh
RUN /tmp/packages/install_packages.sh /tmp/packages/

# Install php extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync
RUN install-php-extensions gd \
    xdebug \
    iconv \
    mcrypt \
    curl \
    mysqli \
    pdo \
    pdo_mysql \
    pgsql \
    mbstring \
    zip \
    soap \
    intl \
    bcmath \
    oauth \
    yaml \
    @composer

# Ignore error if package doesn't exist for php version
RUN install-php-extensions xsd; exit 0
RUN install-php-extensions ioncube_loader; exit 0

# Add php config
COPY config/custom.ini /usr/local/etc/php/conf.d/20-custom.ini
ENV PHP_MEMORY_LIMIT "-1"
ENV PHP_MAX_EXECUTION_TIME "-1"
ENV PHP_POST_MAX_SIZE "100M"
ENV PHP_UPLOAD_MAX_FILESIZE "100M"
ENV PHP_DISPLAY_STARTUP_ERRORS 1
ENV PHP_ERROR_REPORTING "E_ALL"

# Add xdebug config
COPY config/extensions/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
ENV XDEBUG_IDE_KEY "docker"

# Install node js
ENV NODE_MAJOR=18
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
RUN apt-get update \
    && apt-get -y install --no-install-recommends nodejs

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# Set default values
ENV APP_DIR '/var/www/app'

ADD run.sh /usr/bin/run
RUN chmod +x /usr/bin/run
WORKDIR ${APP_DIR}
EXPOSE 22 9000
CMD ["/bin/bash", "/usr/bin/run"]