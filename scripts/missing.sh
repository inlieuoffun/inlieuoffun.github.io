#!/bin/sh
set -euo pipefail

seq 1 631 | while read -r num ; do
    q="$(printf 'transcript-%04d.json' $num)"
    if ! [[ -f "_transcripts/$q" ]] ; then
        echo $q
    fi
done | acat -nonempty missing.txt
