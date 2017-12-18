SHELL := bash

TOP := $(shell git rev-parse --show-toplevel)

include $(TOP)/terraform.mk

.PHONY: default
default: hello

CONFIG_FILES := \
	config/travis-build-com.env \
	config/travis-build-org.env \
	config/travis-com.env \
	config/travis-org.env \
	config/worker-com.env \
	config/worker-org.env \
	$(TFWBZ2)

.PHONY: .config
.config: $(CONFIG_FILES) $(ENV_NAME).tfvars

$(CONFIG_FILES): config/.written

.PHONY: diff-docker-images
diff-docker-images:
	@diff -u \
		--label a/docker-images \
		<($(TOP)/bin/show-current-docker-images) \
		--label b/docker-images \
		<($(TOP)/bin/show-proposed-docker-images "$(ENV_NAME).tfvars")
