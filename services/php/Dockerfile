FROM php:7.3-fpm

RUN apt-get update && apt-get install -y pkg-config \ 
libmagickwand-dev \
build-essential \
libmemcached-dev \
libz-dev \
libpq-dev \
libjpeg-dev \
libfreetype6-dev \
libicu-dev \
libssl-dev \
libmcrypt-dev && \
pecl install memcached-3.1.3 &&\
pecl install imagick 3.4.4 &&\
docker-php-ext-enable memcached imagick

RUN usermod -u 1000 www-data