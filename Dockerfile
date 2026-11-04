# check=skip=InvalidDefaultArgInFrom

# The Makefile supplies the required digest-pinned BASE_IMAGE (wodby/php) and
# BUILD_IMAGE_NGINX (wodby/nginx) arguments.
ARG BASE_IMAGE
ARG BUILD_IMAGE_NGINX

# Moodle's code from its release tag, with the Composer packages a Git checkout
# lacks. Moodle's router and bin/moodle need them.
FROM ${BASE_IMAGE} AS source

ARG MOODLE_VER

RUN set -ex; \
    mkdir -p /tmp/moodle; \
    curl -fsSL --retry 5 "https://github.com/moodle/moodle/archive/refs/tags/v${MOODLE_VER}.tar.gz" \
        | tar -xz --strip-components=1 -C /tmp/moodle; \
    composer install -d /tmp/moodle -n --no-ansi --no-dev --classmap-authoritative; \
    rm -rf /tmp/moodle/.github /tmp/moodle/.grunt /tmp/moodle/.esbuild /home/wodby/.composer/cache

# PHP-FPM with Moodle in /var/www/html: the image Moodle's PHP service and its
# cron worker run.
FROM ${BASE_IMAGE} AS php

ARG MOODLE_VER

ENV APP_NAME="Moodle" \
    MOODLE_VER="${MOODLE_VER}" \
    PHP_MAX_INPUT_VARS="5000" \
    PHP_UPLOAD_MAX_FILESIZE="256M" \
    PHP_POST_MAX_SIZE="256M" \
    PHP_ZEND_EXCEPTION_IGNORE_ARGS="1"

COPY --from=source --chown=wodby:wodby /tmp/moodle /var/www/html
COPY --chown=wodby:wodby config.php /var/www/html/config.php
COPY bin /usr/local/bin/

# Nginx with Moodle's public directory and rules: Nginx serves Moodle's static
# files itself and passes PHP scripts to the PHP image.
FROM ${BUILD_IMAGE_NGINX} AS nginx

ARG MOODLE_VER

ENV APP_NAME="Moodle" \
    MOODLE_VER="${MOODLE_VER}" \
    NGINX_VHOST_PRESET="php" \
    NGINX_SERVER_ROOT="/var/www/html/public" \
    NGINX_CLIENT_MAX_BODY_SIZE="256m"

COPY --from=source --chown=wodby:wodby /tmp/moodle/public /var/www/html/public
# Moodle's rules replace the image's PHP preset. The preset keeps the name php,
# which also makes the image define the PHP-FPM upstream.
COPY templates/moodle.conf.tmpl /etc/gotpl/presets/php.conf.tmpl
