-include env_make

# Accept legacy build arguments during the image revision transition.
BASE_IMAGE_REVISION ?= $(BASE_IMAGE_STABILITY_TAG)

MOODLE_VER ?= 5.3.1
MOODLE_VER_MINOR := $(basename $(MOODLE_VER))
MOODLE_VER_MAJOR := $(basename $(MOODLE_VER_MINOR))

PHP_VER ?= 8.4
BASE_IMAGE_TAG = $(PHP_VER)
ifneq ($(BASE_IMAGE_REVISION),)
    BASE_IMAGE_TAG := $(BASE_IMAGE_TAG)-$(BASE_IMAGE_REVISION)
endif

# Two variants of one Moodle release: PHP-FPM with Moodle (5.3) and Nginx with
# Moodle's public directory (5.3-nginx). CI builds each architecture under its
# own tag and combines them.
TAG ?= $(MOODLE_VER_MINOR)
ARCH_SUFFIX = $(if $(ARCH),-$(ARCH))
PHP_TAG = $(TAG)$(ARCH_SUFFIX)
NGINX_TAG = $(TAG)-nginx$(ARCH_SUFFIX)

REPO = wodby/moodle
NAME = moodle-$(MOODLE_VER_MINOR)

IMAGETOOLS_TAG ?= $(TAG)
SOURCE_TAG ?= $(TAG)

.PHONY: build test push shell clean buildx-imagetools-create

# Resolve the same pinned base images for every local and CI build target.
include base-images.mk

BUILD_ARGS = --build-arg BASE_IMAGE="$(BASE_IMAGE)" --build-arg BUILD_IMAGE_NGINX="$(BUILD_IMAGE_NGINX)" \
	--build-arg MOODLE_VER=$(MOODLE_VER)

default: build

build:
	docker build $(BUILD_ARGS) --target php -t $(REPO):$(PHP_TAG) ./
	docker build $(BUILD_ARGS) --target nginx -t $(REPO):$(NGINX_TAG) ./

test:
	cd ./test && IMAGE=$(REPO):$(PHP_TAG) NGINX_IMAGE=$(REPO):$(NGINX_TAG) MOODLE_VER=$(MOODLE_VER) ./run.sh

push:
	docker push $(REPO):$(PHP_TAG)
	docker push $(REPO):$(NGINX_TAG)

# Combines the architecture images of $(SOURCE_TAG) under $(IMAGETOOLS_TAG).
buildx-imagetools-create:
	docker buildx imagetools create -t $(REPO):$(IMAGETOOLS_TAG) \
				$(REPO):$(SOURCE_TAG)-amd64 \
				$(REPO):$(SOURCE_TAG)-arm64

shell:
	docker run --rm --name $(NAME) -i -t $(REPO):$(PHP_TAG) /bin/bash

clean:
	-docker rm -f $(NAME)
