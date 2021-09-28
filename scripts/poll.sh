#!/bin/zsh
epdate -poll-one -edit |& \
  tea 'Found (\d+) updates on twitter' \
      postnote -audible 'Update ready for editing ($1)'
