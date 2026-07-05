# Base images pinned by digest (supply-chain hardening): the tag is
# human-readable documentation, the digest is what actually gets pulled.
# Digests are kept current by Dependabot (.github/dependabot.yml), which
# cannot resolve ARG-based FROM lines - hence the direct pins. The two
# php FROM lines must stay identical.

# -----------------------------------------------------------------
# Stage 1: composer - Composer binary only
# -----------------------------------------------------------------
FROM composer:2.10@sha256:7725eb4545c438629ae8bde3ef0bb9a5038ef566126ad878442a69007242d267 AS composer

# -----------------------------------------------------------------
# Stage 2: build - compile the production extension set (no xdebug)
# Note: opcache is statically compiled into PHP >= 8.5 and is not
# installable as a shared extension
# -----------------------------------------------------------------
FROM php:8.5-cli-alpine3.24@sha256:bc49fd4f6ea0f46fd45756349747400f668586ee1c4a69c63a436a6b51761350 AS build

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
FROM php:8.5-cli-alpine3.24@sha256:bc49fd4f6ea0f46fd45756349747400f668586ee1c4a69c63a436a6b51761350 AS runtime-base

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
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && mkdir -p ${COMPOSER_HOME} \
    && chown www-data:www-data ${COMPOSER_HOME}

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY config/base/php.ini /usr/local/etc/php/php.ini
COPY config/opcache.ini /usr/local/etc/php/conf.d/10-opcache.ini

WORKDIR /var/www/html/

# Never run as root: artisan, horizon and scheduler all run as www-data.
# Downstream Dockerfiles that need apk/pecl must toggle USER root and back.
USER www-data

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
