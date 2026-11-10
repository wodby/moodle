# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := wodby/php
BASE_IMAGE_VERSION_SUFFIX :=

BASE_IMAGE_DIGEST_8.4 := sha256:14e4d8917fbbe6bdc41617c7155661caed57f4ec92301a6e07a75bcc854814c5
BASE_IMAGE_DIGEST_8.4-r13 := sha256:dae2647f10707d86ad57c096cf0df38ffbb9dc9c104f1e758dba984adcb68ab5

# The Nginx variant's base, refreshed with the base image pins.
BUILD_IMAGE_NGINX := wodby/nginx:1.31-r18@sha256:152dbec8b218710b5bbea69cc0cd05be2c35c8b801db028cd9644c70bb072b7c

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
