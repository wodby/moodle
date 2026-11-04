#!/usr/bin/env bash

set -euo pipefail

if [[ -n "${DEBUG:-}" ]]; then
    set -x
fi

cleanup() {
    docker compose down -v
}
trap cleanup EXIT

docker compose up -d mariadb moodle
docker compose exec -T moodle sh -c 'until php -r "exit(@fsockopen(\"mariadb\", 3306) ? 0 : 1);"; do sleep 1; done'
docker compose up -d nginx

moodle() {
    docker compose exec -T moodle "$@"
}

# Fetches a URL through Nginx and prints its status code.
status() {
    moodle curl -s -o /dev/null -w '%{http_code}' "http://nginx$1"
}

check() {
    local actual
    actual=$(status "$1")
    if [[ "${actual}" != "$2" ]]; then
        echo >&2 "Expected $2 for $1, got ${actual}"
        exit 1
    fi
    echo "OK: $1 -> ${actual}"
}

echo "Checking the installed version"
moodle sh -c 'release=$(sed -n "s/^\$release *= *.\([^ ]*\) .*/\1/p" public/version.php); case "${release}" in "${MOODLE_VER%.0}") echo "Moodle ${release}" ;; *) echo >&2 "Unexpected release ${release}"; exit 1 ;; esac'

echo "Installing"
moodle moodle-update
moodle php -r 'define("CLI_SCRIPT", true); require "config.php"; exit(get_admin()->username === "admin" && $SITE->shortname === "test" ? 0 : 1);'

echo "Upgrading an installed site"
# Moodle prints this on stderr.
moodle moodle-update 2>&1 | grep "No upgrade needed"

check /login/index.php 200
check "/theme/styles.php?theme=boost&rev=1_1&type=all" 200
check /pix/moodlelogo.svg 200
check /lib/javascript.php/1/lib/javascript-static.js 200
check /does-not-exist 404
check /composer.json 404
check /.git/config 403

echo "Running cron"
docker compose up -d cron
# grep reads all of the logs: with -q it would close the pipe early, which fails under pipefail.
for i in $(seq 1 30); do
    if docker compose logs cron 2>&1 | grep "Cron run completed correctly" >/dev/null; then
        break
    fi
    sleep 2
done
docker compose logs cron 2>&1 | grep "Cron run completed correctly" >/dev/null

echo "Stopping cron"
docker compose stop -t 20 cron
test "$(docker inspect -f '{{.State.ExitCode}}' "$(docker compose ps -a -q cron)")" = 0
