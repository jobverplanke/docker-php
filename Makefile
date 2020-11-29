SHELL := /bin/bash

build-74-fpm-dev:
	@docker build --no-cache \
		--build-arg PHP_VERSION=7.4 \
		--build-arg XDEBUG_VERSION=3.0.0 \
		--build-arg COMPOSER_VERSION=2.0 \
		--build-arg REDIS_VERSION=5.3.2 \
		-t jobverplanke/php:7.4-fpm-dev ./7.4/fpm-dev

run-74-fpm-dev:
	@docker run --rm -it jobverplanke/php:7.4-fpm-dev sh


build-80-fpm-dev:
	@docker build --no-cache \
		--build-arg PHP_VERSION=8.0 \
		--build-arg XDEBUG_VERSION=3.0.0 \
		--build-arg COMPOSER_VERSION=2.0 \
		--build-arg REDIS_VERSION=5.3.2 \
		-t jobverplanke/php:8.0-fpm-dev ./8.0/fpm-dev

run-80-fpm-dev:
	@docker run --rm -it jobverplanke/php:8.0-fpm-dev sh
