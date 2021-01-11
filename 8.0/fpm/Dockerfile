ARG COMPOSER_VERSION=2.0
ARG PHP_VERSION

FROM composer:${COMPOSER_VERSION} as composer
FROM php:${PHP_VERSION}-fpm-alpine3.12

LABEL maintainer="Job Verplanke <job.verplanke@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/jobverplanke/docker-php"

ENV PATH="${PATH}:/root/.composer/vendor/bin" \
    COMPOSER_ALLOW_SUPERUSER=1

COPY --from=composer /usr/bin/composer /usr/bin/composer

ARG TZ=Europa/Amsterdam
ARG XDEBUG_VERSION=3.0.0
ARG REDIS_VERSION=5.3.2

RUN set -eux \
    && apk add --no-cache tzdata \
    && ln -s /usr/share/zoneinfo/${TZ} /etc/localtime \
    && apk add --no-cache --virtual .phpize-deps wget $PHPIZE_DEPS \
    && wget http://pear.php.net/go-pear.phar \
    && php go-pear.phar \
    && pecl update-channels \
    && apk add --no-cache --update \
        libzip-dev \
        libpng-dev \
        oniguruma-dev \
        libxml2-dev \
        libzip-dev \
        icu-dev \
        zlib-dev \
    && docker-php-source extract \
    && pecl install xdebug-${XDEBUG_VERSION} \
    && pecl install redis-${REDIS_VERSION} \
    && docker-php-ext-enable redis \
    && docker-php-source delete \
    && docker-php-ext-install \
        bcmath \
        gd \
        intl \
        opcache \
        pcntl \
        pdo_mysql \
        zip \
    && apk del .phpize-deps \
    && rm -rf /tmp/* \
    && rm -rf ~/.pearrc go-pear.phar

COPY ./config/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./config/php.ini /usr/local/etc/php/php.ini
COPY ./config/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./config/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

WORKDIR /var/www/html/
