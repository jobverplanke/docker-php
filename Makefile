SHELL := /bin/bash

build-74-fpm:
	@docker build \
		--no-cache \
		--build-arg PHP_VERSION=7.4 \
		-t jobverplanke/php:7.4-fpm \
		./7.4/fpm

build-80-fpm:
	@docker build \
		--no-cache \
		--build-arg PHP_VERSION=8.0 \
		-t jobverplanke/php:8.0-fpm ./8.0/fpm

run-74-fpm:
	@docker run --rm -it jobverplanke/php:7.4-fpm sh

mods-74-fpm:
	@docker run --rm jobverplanke/php:7.4-fpm php -m

run-80-fpm-dev:
	@docker run --rm -it jobverplanke/php:8.0-fpm sh

mods-80-fpm:
	@docker run --rm jobverplanke/php:8.0-fpm php -m
