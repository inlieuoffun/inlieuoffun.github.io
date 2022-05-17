#!/bin/sh
set -euo pipefail

curl -s https://inlieuof.fun/episodes.json | \
    jq -r '.episodes[]|select(.youTubeURL).episode' | while read -r ep ; do
    fn="$(printf '_transcripts/transcript-0%03s.json' $ep)"
    if [[ ! -f "$fn" ]] ; then
        echo "$ep"
    fi
done
