SHELL := /bin/bash

build-74fpm-dev:
	@docker build --no-cache \
		--build-arg PHP_VERSION=7.4 \
		--build-arg XDEBUG_VERSION=2.9.8 \
		--build-arg COMPOSER_VERSION=2.0 \
		--build-arg REDIS_VERSION=5.3.1 \
		-t jobverplanke/php:7.4-fpm-dev ./7.4/fpm-dev


run-74-fpm-dev:
	@docker run --rm -it jobverplanke/php:7.4-fpm-dev sh
