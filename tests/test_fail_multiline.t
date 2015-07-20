#!/usr/bin/env bash
. ../bash_tap.sh

# Multi-line statements lead to errors. Make sure we output valid TAP
# information in this case.
if true; then
    echo "this will lead to errors"
fi
