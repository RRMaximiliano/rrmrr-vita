#!/bin/sh
# Lists links in the CV that don't load.
# Usage: tools/check-links.sh cv-content.tex
# Fails only on links that are gone (404 and other 4xx). Sites that refuse
# scripted requests (403, 429), time out (000), or error (5xx) are listed
# as "recheck": open those in a browser.
set -u
grep -hoE 'https?://[^]}{ %]+' "$@" | sed 's/\\//g' | sort -u |
  xargs -P 8 -n 1 sh -c \
    'echo "$(curl -sL -o /dev/null -w "%{http_code}" -A "Mozilla/5.0" --max-time 20 "$1") $1"' _ |
  sort | awk '
    $1 >= 200 && $1 < 400 { ok++; next }
    $1 == 403 || $1 == 429 || $1 == 0 || $1 >= 500 { print "recheck " $0; recheck++; next }
    { print "BROKEN  " $0; broken++ }
    END {
      printf "%d OK, %d to recheck in a browser, %d broken\n", ok, recheck, broken
      exit broken > 0
    }'
