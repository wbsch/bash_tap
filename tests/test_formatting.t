#!/usr/bin/env bash
. ../bash_tap.sh

if [ "foo" != "bar" ]; then echo "foo is not bar"; fi

echo "keep this sane: \n \e \t %s %d"

echo "Let's include" quotes in quotes
