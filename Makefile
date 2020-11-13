SHELL := /bin/bash

php74-xdebug:
	@docker build --no-cache \
		--build-arg COMPOSER_VERSION=2.0 \
		--build-arg PHP_VERSION=7.4 \
		--build-arg XDEBUG_VERSION=2.9.8 \
		-t jobverplanke/php:7.4-cli-xdebug ./7.4/cli-xdebug

php74-fpm:
	@docker build --no-cache \
		--build-arg COMPOSER_VERSION=2.0 \
		--build-arg PHP_VERSION=7.4 \
		--build-arg REDIS_VERSION=5.3.1 \
		-t jobverplanke/php:7.4-fpm ./7.4/fpm

run-php74-xdebug:
	@docker run --rm -it jobverplanke/php:7.4-cli-xdebug sh

run-php74-fpm:
	@docker run --rm -it jobverplanke/php:7.4-fpm sh
