#!/bin/zsh
epdate -poll-one -edit -skip-video-check |& \
  tea 'Found (\d+) updates on twitter' \
      postnote -audible 'Update ready for editing ($1)'
