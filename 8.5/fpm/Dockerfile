# Base images pinned by digest (supply-chain hardening): the tag is
# human-readable documentation, the digest is what actually gets pulled.
# Digests are kept current by Dependabot (.github/dependabot.yml), which
# cannot resolve ARG-based FROM lines - hence the direct pins. The two
# php FROM lines must stay identical.

# -----------------------------------------------------------------
# Stage 1: composer - Composer binary only
# -----------------------------------------------------------------
FROM composer:2.10@sha256:2cf275428757e5435a667bfc0d038b14520ca02be2b1b70d44a05c8c19e2de48 AS composer

# -----------------------------------------------------------------
# Stage 2: build - compile the extension set
# Note: opcache is statically compiled into PHP >= 8.5 and is not
# installable as a shared extension
# -----------------------------------------------------------------
FROM php:8.5-fpm-alpine3.24@sha256:4c2818074ec49f6abe46620f3965e0cb75bc3a5f2b417edd1aacaba6f091c40e AS build

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
# Stage 3: runtime-base - runtime packages, config and user
# -----------------------------------------------------------------
FROM php:8.5-fpm-alpine3.24@sha256:4c2818074ec49f6abe46620f3965e0cb75bc3a5f2b417edd1aacaba6f091c40e AS runtime-base

LABEL maintainer="Job Verplanke <job@verplanke.dev>"
LABEL org.opencontainers.image.source="https://github.com/jobverplanke/docker-php"

ENV COMPOSER_HOME=/composer \
    PATH="${PATH}:/composer/vendor/bin"

ARG TZ=Europe/Amsterdam

# apk upgrade pulls in Alpine security fixes that the pinned base image does
# not carry yet, so the Trivy gate does not have to wait for an upstream
# rebuild. The scan in the workflow checks the result.
RUN set -eux \
    && apk upgrade --no-cache \
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
# Stage 4: production - final image with the compiled extensions
# -----------------------------------------------------------------
FROM runtime-base AS production

COPY --from=build /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=build /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

COPY config/prod/php.ini /usr/local/etc/php/conf.d/zz-90-php.ini
COPY config/prod/opcache.ini /usr/local/etc/php/conf.d/zz-91-opcache.ini
