#!/bin/bash
epdate -poll -edit |& \
  tea 'Found (\d+) updates on twitter' \
      postnote -audible 'Update ready for editing ($1)'
