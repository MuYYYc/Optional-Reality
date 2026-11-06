#!/usr/bin/env bash
# Game frontend only. Run on muuyyy: bash switch-site.sh [--check] NEW_RELEASE EXPECTED_CURRENT
set -euo pipefail
check_only=false
if [ "${1:-}" = --check ]; then
    check_only=true
    shift
fi
if [ "$#" -ne 2 ]; then
    echo 'Usage: switch-site.sh [--check] NEW_RELEASE EXPECTED_CURRENT' >&2
    exit 2
fi
root=/var/www/games
for path in "$1" "$2"; do
    case "$path" in "$root"/releases/*) ;; *) echo 'Game releases must be under /var/www/games/releases/' >&2; exit 2 ;; esac
done
release=$(realpath -e -- "$1")
expected=$(realpath -e -- "$2")
for path in "$release" "$expected"; do
    case "$path" in "$root"/releases/*) ;; *) echo 'Resolved game release is outside /var/www/games/releases/' >&2; exit 2 ;; esac
done
[ -d "$release" ] && [ -f "$release/index.html" ] && [ -f "$release/demo/index.html" ]
[ -L "$root/current" ]
[ "$(realpath -e -- "$root")" = /var/www/games ] || { echo 'Game root must resolve to /var/www/games' >&2; exit 2; }
case "$(readlink -f -- "$root/current")" in /var/www/games/releases/*) ;; *) echo 'Game current points outside games/releases' >&2; exit 2 ;; esac
[ "$(readlink -f -- "$root/current")" = "$expected" ] || { echo 'Current site changed; stop and investigate' >&2; exit 1; }
apache2ctl configtest
if "$check_only"; then
    printf 'Check passed; no links changed.\nGame release: %s\nExpected current: %s\n' "$release" "$expected"
    exit 0
fi
next="$root/.current-next-$$"
trap 'if [ -L "$next" ]; then rm -- "$next"; fi' EXIT
ln -s -- "$release" "$next"
[ "$(readlink -f -- "$root/current")" = "$expected" ] || { echo 'Current site changed before switch' >&2; exit 1; }
mv -Tf -- "$next" "$root/current"
printf 'Current site: %s\nPrevious site: %s\n' "$release" "$expected"
