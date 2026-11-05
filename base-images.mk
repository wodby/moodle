# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := wodby/php
BASE_IMAGE_VERSION_SUFFIX :=

BASE_IMAGE_DIGEST_8.4 := sha256:b464606f70745b777cb91f8e9ae7a20d22c4b76d1b493ad77e1ab95f9960ac89
BASE_IMAGE_DIGEST_8.4-r11 := sha256:c968e9eac983eab34b5873f4c5dcd4cfbf53673ba3fe14fa87ce037379262226

# The Nginx variant's base, refreshed with the base image pins.
BUILD_IMAGE_NGINX := wodby/nginx:1.31-r18@sha256:152dbec8b218710b5bbea69cc0cd05be2c35c8b801db028cd9644c70bb072b7c

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
