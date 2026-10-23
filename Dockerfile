ARG SOURCE_TAG=php:fpm
FROM ${SOURCE_TAG}
LABEL vendor="foun10 GmbH"
LABEL maintainer="Alexander Schneider <schneider@foun10.com>"

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
    amqp \
    ftp \
    @composer

# Ignore error if package doesn't exist for php version
RUN install-php-extensions xsd; exit 0
RUN install-php-extensions ioncube_loader; exit 0

# Add php config
COPY config/custom.ini /usr/local/etc/php/conf.d/20-custom.ini
ENV PHP_MEMORY_LIMIT=-1
ENV PHP_MAX_EXECUTION_TIME=-1
ENV PHP_POST_MAX_SIZE=100M
ENV PHP_UPLOAD_MAX_FILESIZE=100M
ENV PHP_DISPLAY_STARTUP_ERRORS=1
ENV PHP_ERROR_REPORTING=E_ALL

# Add xdebug config
COPY config/extensions/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
ENV XDEBUG_MODE=off
ENV XDEBUG_IDE_KEY=docker
ENV XDEBUG_START_WITH_REQUEST=no
ENV XDEBUG_LOG=/dev/stdout
ENV XDEBUG_LOG_LEVEL=0
ENV XDEBUG_CLIENT_HOST=host.docker.internal
ENV XDEBUG_CLIENT_PORT=9003
ENV XDEBUG_MAX_NESTING_LEVEL=1024

# Install node js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash

# set env
ENV NODE_VERSION=18
ENV NVM_DIR=/root/.nvm
# install node
RUN bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION"

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# Set default values
ENV APP_DIR=/var/www/html

ADD run.sh /usr/bin/run
RUN chmod +x /usr/bin/run
WORKDIR ${APP_DIR}
EXPOSE 22 9000
CMD ["/bin/bash", "/usr/bin/run"]