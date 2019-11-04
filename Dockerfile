ARG SOURCE_TAG=php:fpm
FROM ${SOURCE_TAG}
MAINTAINER Alexander Schneider <schneider@foun10.com>

# Install packages
ADD packages /tmp/packages
RUN chmod +x /tmp/packages/install_packages.sh
RUN /tmp/packages/install_packages.sh /tmp/packages/

# Install php extensions
ADD extensions /tmp/php/extensions
RUN chmod +x /tmp/php/extensions/install_extensions.sh
RUN /tmp/php/extensions/install_extensions.sh /tmp/php/extensions/

# Install composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install node js
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y nodejs

# Install compass
RUN if ! type "gem" > /dev/null; then apt-get install -y rubygems; fi
RUN gem update --system --conservative || (gem i "rubygems-update:~>2.7" --no-document && update_rubygems)
RUN gem install compass || gem install rb-inotify -v 0.9.10 && gem install compass

# Set default values
ENV APP_DIR '/var/www/app'
ENV HTDOCS_DIR ''
ENV DB_HOST 'mysql'
ENV DB_USER 'root'
ENV DB_PASS 'root'
ENV DB_NAME 'app'
ENV DB_DUMP ''
ENV BACKUP_URL ''
ENV BACKUP_USER ''
ENV BACKUP_PASS ''
ENV PROJECT_URL ''
ENV PROJECT_TYPE ''
ENV USER_MAIL 'dev@local.docker'
ENV USER_PASS 'root'
ENV FILE_PERMISSIONS ''

ADD run.sh /usr/bin/run
RUN chmod +x /usr/bin/run
WORKDIR /var/www/app
EXPOSE 22 9000
CMD ["/bin/bash", "/usr/bin/run"]