ARG COMPOSER_VERSION
ARG PHP_VERSION

FROM composer:${COMPOSER_VERSION} as composer
FROM php:${PHP_VERSION}-cli-alpine3.12

LABEL maintainer="Job Verplanke <job.verplanke@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/jobverplanke/docker-php"

ARG XDEBUG_VERSION

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    PATH="${PATH}:/root/.composer/vendor/bin" \
    TZ='Europa/Amsterdam'

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN set -eux \
    && apk add --no-cache tzdata \
    && ln -s /usr/share/zoneinfo/${TZ} \
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
    && docker-php-source delete \
    && docker-php-ext-install \
        bcmath \
        gd \
        intl \
        opcache \
        pcntl \
        pdo \
        pdo_mysql \
        zip \
    && apk del .phpize-deps \
    && rm -rf /tmp/* \
    && rm -rf ~/.pearrc go-pear.phar

COPY ./php.ini /usr/local/etc/php/php.ini
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

WORKDIR /var/www/html/
