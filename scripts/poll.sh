#!/bin/bash
epdate -poll -edit |& \
  tea 'Found (\d+) updates on twitter' \
      postnote -audible '$1 episode update is ready for editing'
