FROM php:8.2-fpm-alpine

SHELL ["/bin/ash", "-oeux", "pipefail", "-c"]

# timezone
ARG TZ

RUN apk add --no-cache linux-headers

RUN apk update && \
  apk add --update --no-cache --virtual=.build-dependencies \
  autoconf \
  gcc \
  g++ \
  make \
  tzdata \
  git && \
  apk add libpng libpng-dev libjpeg-turbo-dev libwebp-dev zlib-dev libxpm-dev gd supervisor && \
  apk add --update --no-cache \
  icu-dev \
  libzip-dev \
  oniguruma-dev && \
  cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
  echo ${TZ} > /etc/timezone && \
  apk del .build-dependencies && \
  docker-php-ext-install intl pdo_mysql mbstring zip bcmath gd sockets

# Install Node.js and npm
RUN apk add --update --no-cache nodejs npm

# service
COPY startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

# composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Change current user to www
USER www-data

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
