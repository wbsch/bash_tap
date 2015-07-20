#!/bin/bash
. ../bash_tap.sh

# This successfully finds "world" and exits with a zero exit code:
echo "Hello world" | grep "world"
# This cannot find "cookies" in the text, so it exits non-zero:
echo "Got milk?" | grep "cookies"
