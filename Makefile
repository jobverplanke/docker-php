SHELL := /bin/bash

build-80-cli:
	@docker build \
		--no-cache \
		--build-arg PHP_VERSION=8.0 \
		-t jobverplanke/php:8.0-cli \
		./8.0/cli

build-80-fpm:
	@docker build \
		--no-cache \
		--build-arg PHP_VERSION=8.0 \
		-t jobverplanke/php:8.0-fpm \
		./8.0/fpm

build-74-cli:
	@docker build \
		--no-cache \
		--build-arg PHP_VERSION=7.4 \
		-t jobverplanke/php:7.4-cli \
		./7.4/cli

build-74-fpm:
	@docker build \
		--no-cache \
		--build-arg PHP_VERSION=7.4 \
		-t jobverplanke/php:7.4-fpm \
		./7.4/fpm

run-80-cli:
	@docker run --rm -it jobverplanke/php:8.0-cli sh

run-80-fpm:
	@docker run --rm -it jobverplanke/php:8.0-fpm sh

mods-80-cli:
	@docker run --rm jobverplanke/php:8.0-cli php -m

mods-80-fpm:
	@docker run --rm jobverplanke/php:8.0-fpm php -m

run-74-cli:
	@docker run --rm -it jobverplanke/php:7.4-cli sh

run-74-fpm:
	@docker run --rm -it jobverplanke/php:7.4-fpm sh

mods-74-cli:
	@docker run --rm jobverplanke/php:7.4-cli php -m

mods-74-fpm:
	@docker run --rm jobverplanke/php:7.4-fpm php -m
