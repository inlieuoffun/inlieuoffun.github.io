poke() {
    local ep="${1:?missing episode}"
    fytt -episode "$ep" | acat -nonempty _transcripts/transcript-0"$ep".json
}
