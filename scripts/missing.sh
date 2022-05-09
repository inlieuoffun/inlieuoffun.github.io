#!/bin/sh
set -euo pipefail

latest="$(curl -s https://inlieuof.fun/latest.json | jq -r .latest.episode)"
seq 1 "$latest" | while read -r num ; do
    q="$(printf 'transcript-%04d.json' $num)"
    if ! [[ -f "_transcripts/$q" ]] ; then
        echo $q
    fi
done | acat -nonempty missing.txt
