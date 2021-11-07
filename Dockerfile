FROM composer:2.0.7 as build

FROM php:7.4-apache
ARG BUILD_ENV
RUN apt-get update -y
RUN apt-get install -y git unzip lftp gnupg curl wget libcurl4-openssl-dev libpng-dev libfreetype6-dev libjpeg-dev libjpeg62-turbo-dev zlib1g-dev libpq-dev libxml2-dev libzip-dev libgmp-dev
RUN docker-php-ext-install curl
RUN docker-php-ext-install pgsql
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install xml
RUN docker-php-ext-install gmp
RUN docker-php-ext-install json
RUN docker-php-ext-configure pcntl --enable-pcntl
RUN docker-php-ext-install \
    bcmath \
    intl \
    pcntl \
    soap \
    sockets \
    zip
RUN if [ "$HTTP_PROXY" ] ; then pear config-set http_proxy $HTTP_PROXY; fi
RUN pecl install -o -f redis &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis
# only install and activate xdebug on local docker build
RUN if [ "$BUILD_ENV" = "local" ] ; then pecl install -o -f xdebug &&  rm -rf /tmp/pear; docker-php-ext-enable xdebug; fi

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# on local docker build use the development php.ini, otherwise use the production version of the image
RUN if [ "$BUILD_ENV" = "local" ] ; then mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini";  else mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; fi
RUN sed -i 's/pgsql.auto_reset_persistent = Off/pgsql.auto_reset_persistent = On/g' "$PHP_INI_DIR/php.ini"
RUN a2enmod rewrite

RUN mkdir -p /tmp/temp
RUN chmod 777 /tmp/temp
RUN mkdir -p /tmp/cache
RUN chmod 777 /tmp/cache
RUN mkdir -p /tmp/templates_c
RUN chmod 777 /tmp/templates_c

COPY --from=build /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html/
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

#RUN docker exec container_id [ -d "/var/www" ] && echo "Exists" || echo "Does not exist"

#RUN composer install
CMD bash -c "composer install --dev";
