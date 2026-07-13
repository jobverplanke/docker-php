# Base images pinned by digest (supply-chain hardening): the tag is
# human-readable documentation, the digest is what actually gets pulled.
# Digests are kept current by Dependabot (.github/dependabot.yml), which
# cannot resolve ARG-based FROM lines - hence the direct pins. The two
# php FROM lines must stay identical.

# -----------------------------------------------------------------
# Stage 1: composer - Composer binary only
# -----------------------------------------------------------------
FROM composer:2.10@sha256:5946476338742b200bb9ff88f8be56275ddae4b3949c72305cb0dbf10cfcb760 AS composer

# -----------------------------------------------------------------
# Stage 2: build - compile the production extension set (no xdebug)
# Note: opcache is statically compiled into PHP >= 8.5 and is not
# installable as a shared extension
# -----------------------------------------------------------------
FROM php:8.5-fpm-alpine3.24@sha256:79def1d16ece3ab1a6656c46a23bfd80ad33887fbd33626e7bd743cef54ef9c6 AS build

ARG REDIS_VERSION=6.3.0
ARG IMAGICK_VERSION=3.8.1

RUN set -eux \
    && apk add --no-cache \
        $PHPIZE_DEPS \
        linux-headers \
        libzip-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        libwebp-dev \
        freetype-dev \
        icu-dev \
        zlib-dev \
        imagemagick-dev \
    && pecl update-channels \
    && pecl install redis-${REDIS_VERSION} \
    && pecl install imagick-${IMAGICK_VERSION} \
    && docker-php-ext-enable imagick redis \
    && docker-php-ext-configure gd \
        --with-jpeg \
        --with-webp \
        --with-freetype \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        gd \
        intl \
        pcntl \
        pdo_mysql \
        zip

# -----------------------------------------------------------------
# Stage 3: build-dev - inherits the production set, adds xdebug.
# Activation happens via config/dev/xdebug.ini in the dev
# stage, so conf.d stays identical to the build stage.
# -----------------------------------------------------------------
FROM build AS build-dev

ARG XDEBUG_VERSION=3.5.3

RUN set -eux \
    && pecl install xdebug-${XDEBUG_VERSION}

# -----------------------------------------------------------------
# Stage 4: runtime-base - shared foundation for dev and production
# -----------------------------------------------------------------
FROM php:8.5-fpm-alpine3.24@sha256:79def1d16ece3ab1a6656c46a23bfd80ad33887fbd33626e7bd743cef54ef9c6 AS runtime-base

LABEL maintainer="Job Verplanke <job@verplanke.dev>"
LABEL org.opencontainers.image.source="https://github.com/jobverplanke/docker-php"

ENV COMPOSER_HOME=/composer \
    PATH="${PATH}:/composer/vendor/bin"

ARG TZ=Europe/Amsterdam

RUN set -eux \
    && apk add --no-cache \
        tzdata \
        libzip \
        libpng \
        libjpeg-turbo \
        libwebp \
        freetype \
        icu-libs \
        icu-data-full \
        imagemagick \
        imagemagick-jpeg \
        imagemagick-webp \
        fcgi \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && mkdir -p ${COMPOSER_HOME} \
    && chown www-data:www-data ${COMPOSER_HOME}

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY config/base/php.ini /usr/local/etc/php/php.ini
COPY config/fpm/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY config/opcache.ini /usr/local/etc/php/conf.d/10-opcache.ini
COPY config/fpm/php.ini /usr/local/etc/php/conf.d/zz-95-fpm.ini
COPY --chmod=755 fpm/php-fpm-healthcheck /usr/local/bin/php-fpm-healthcheck

WORKDIR /var/www/html/

# Never run as root: the fpm master and workers all run as www-data.
# Downstream Dockerfiles that need apk/pecl must toggle USER root and back.
USER www-data

# Real fpm health (ping through the status listener), not just an open port.
# Kubernetes ignores this and should use an exec probe with the same script.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
    CMD ["php-fpm-healthcheck"]

# -----------------------------------------------------------------
# Stage 5: dev - extensions incl. xdebug, plus dev overlays
# -----------------------------------------------------------------
FROM runtime-base AS dev

COPY --from=build-dev /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=build-dev /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

COPY config/dev/php.ini /usr/local/etc/php/conf.d/zz-90-php.ini
COPY config/dev/opcache.ini /usr/local/etc/php/conf.d/zz-91-opcache.ini
COPY config/dev/xdebug.ini /usr/local/etc/php/conf.d/zz-92-xdebug.ini

# -----------------------------------------------------------------
# Stage 6: production - default target (no xdebug, JIT active)
# -----------------------------------------------------------------
FROM runtime-base AS production

COPY --from=build /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=build /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

COPY config/prod/php.ini /usr/local/etc/php/conf.d/zz-90-php.ini
COPY config/prod/opcache.ini /usr/local/etc/php/conf.d/zz-91-opcache.ini
