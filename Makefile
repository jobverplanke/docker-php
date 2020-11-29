SHELL := /bin/bash

build-74-fpm:
	@docker build --no-cache \
		--build-arg PHP_VERSION=7.4 \
		--build-arg COMPOSER_VERSION=2.0 \
		--build-arg TZ=Europa/Amsterdam \
		-t jobverplanke/php:7.4-fpm ./7.4/fpm

run-74-fpm:
	@docker run --rm -it jobverplanke/php:7.4-fpm sh


build-80-fpm:
	@docker build --no-cache \
		--build-arg PHP_VERSION=8.0 \
		--build-arg COMPOSER_VERSION=2.0 \
		--build-arg TZ=Europa/Amsterdam \
		-t jobverplanke/php:8.0-fpm ./8.0/fpm

run-80-fpm-dev:
	@docker run --rm -it jobverplanke/php:8.0-fpm sh
