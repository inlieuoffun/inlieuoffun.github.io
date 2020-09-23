#!/bin/sh
set -e
set -o pipefail
if [[ "$(hub ci-status)" = "success" ]] ; then
    echo "Build already complete." 1>&2
    exit 0
fi
while [[ "$(hub ci-status)" != "pending" ]] ; do
    sleep 3
done
echo "Build in progress..." 1>&2
while [[ "$(hub ci-status)" = "pending" ]] ; do
    sleep 10
done
echo "Build complete." 1>&2
