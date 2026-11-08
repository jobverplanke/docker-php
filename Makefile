SHELL := /bin/bash
IMAGE := jobverplanke/php

# Multi-stage images; the production target is the published image.
# Build context is the version directory so Dockerfiles can COPY from config/.
# $(1) = version dir, $(2) = variant, $(3) = target suffix (e.g. 85-fpm)
define IMAGE_RULES
build-$(3):
	@docker build --target production -f $(1)/$(2)/Dockerfile -t $(IMAGE):$(1)-$(2) $(1)

run-$(3):
	@docker run --rm -it $(IMAGE):$(1)-$(2) sh

mods-$(3):
	@docker run --rm $(IMAGE):$(1)-$(2) php -m
endef

$(eval $(call IMAGE_RULES,8.5,fpm,85-fpm))
$(eval $(call IMAGE_RULES,8.5,cli,85-cli))
