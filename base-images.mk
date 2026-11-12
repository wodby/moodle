# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := wodby/php
BASE_IMAGE_VERSION_SUFFIX :=

BASE_IMAGE_DIGEST_8.4 := sha256:6139bf01f51a0b7f378711a2eae92b3242942bc395e8f2e3abdf902df440735e
BASE_IMAGE_DIGEST_8.4-r14 := sha256:2e050870914947b2c711526306969f5c310d2c4e1c7a583c08a95e51ccfab74d

# The Nginx variant's base, refreshed with the base image pins.
BUILD_IMAGE_NGINX := wodby/nginx:1.31-r18@sha256:152dbec8b218710b5bbea69cc0cd05be2c35c8b801db028cd9644c70bb072b7c

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
