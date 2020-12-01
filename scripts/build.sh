#!/bin/sh
set -e
set -o pipefail
bundle exec jekyll serve --host 0.0.0.0 "$@" |
    tea -- '\bdone in (\d+\.\d)\d* seconds' \
        postnote -audible 'Build complete after $1 seconds'
