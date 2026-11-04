# Moodle Docker Container Image

[![Build Status](https://github.com/wodby/moodle/workflows/Build%20docker%20image/badge.svg)](https://github.com/wodby/moodle/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/moodle.svg)](https://hub.docker.com/r/wodby/moodle)

[Moodle LMS](https://moodle.org/) with its Composer packages, ready to run on Kubernetes with Wodby.

## Docker Images

Use image revision tags such as `wodby/moodle:5.3-rN` to select a Wodby image revision.
Major and minor tags use the repository release number, starting at `r0`. Full-version tags such as
`wodby/moodle:5.3.0-r0` start at `r0` for each exact upstream version.
Every published versioned revision tag has a matching annotated Git tag pointing to its release commit.
See [release tags](https://github.com/wodby/moodle/tags) for available revisions and the
[image revision policy](https://github.com/wodby/images#image-revisions) for upgrade guidance.

Each Moodle release has two variants:

| Variant | Tags | Base image | Contents |
| --- | --- | --- | --- |
| PHP-FPM | `5.3`, `5`, `latest` | [wodby/php](https://github.com/wodby/php) 8.4 | Moodle in `/var/www/html`, `config.php`, `moodle-update`, `moodle-cron` |
| Nginx | `5.3-nginx`, `5-nginx`, `nginx` | [wodby/nginx](https://github.com/wodby/nginx) | Moodle's `public` directory in `/var/www/html/public` and Moodle's rules |

- All images are based on Alpine Linux and built for `amd64` and `arm64`
- [GitHub Actions builds](https://github.com/wodby/moodle/actions)
- [Docker Hub](https://hub.docker.com/r/wodby/moodle)

## Configuration

`config.php` reads every setting from the environment:

| Variable | Default | Description |
| --- | --- | --- |
| `DB_KIND` | `mariadb` | `mariadb`, `mysql` or `postgres` |
| `DB_HOST` | `localhost` | |
| `DB_PORT` | | The driver's default when empty |
| `DB_NAME` | `moodle` | |
| `DB_USERNAME` | `moodle` | |
| `DB_PASSWORD` | | |
| `DB_SSL_CA` | | CA certificate of the database server; connects over TLS when set |
| `MOODLE_DB_PREFIX` | `mdl_` | |
| `MOODLE_WWWROOT` | `WODBY_PRIMARY_URL`, else `http://localhost` | Moodle's address; `https://` addresses turn on `sslproxy` |
| `MOODLE_DATAROOT` | `/mnt/files/moodledata` | Moodle's data directory; share it between containers |
| `MOODLE_LOCALCACHEDIR` | `/tmp/moodle-localcache` | |
| `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD` | | Keep sessions in Redis or Valkey when `REDIS_HOST` is set |
| `MOODLE_SESSION_REDIS_PREFIX` | `moodle_sess_` | |

The PHP variant also sets `PHP_MAX_INPUT_VARS=5000`, `PHP_UPLOAD_MAX_FILESIZE=256M`, `PHP_POST_MAX_SIZE=256M` and
`PHP_ZEND_EXCEPTION_IGNORE_ARGS=1`. See [wodby/php](https://github.com/wodby/php) for all PHP variables.

Installing plugins from Moodle's web interface is turned off, because the image replaces Moodle's code.

## Commands

- `moodle-update` installs Moodle into an empty database or upgrades an installed site. The administrator comes from
  `MOODLE_ADMIN_USERNAME` (default `admin`), `MOODLE_ADMIN_PASSWORD` (required to install) and `MOODLE_ADMIN_EMAIL`;
  the site's names from `MOODLE_SITE_FULLNAME` and `MOODLE_SITE_SHORTNAME`. A password that doesn't meet Moodle's
  password policy must be changed at the first sign-in.
- `moodle-cron` keeps Moodle's cron running and passes a stop on to it, so the running task finishes.

## Nginx variant

The Nginx variant passes PHP scripts to `NGINX_BACKEND_HOST` (default `php`) on port 9000. Requests for paths that don't
exist go to Moodle's router, `r.php`. See [wodby/nginx](https://github.com/wodby/nginx) for all Nginx variables.
