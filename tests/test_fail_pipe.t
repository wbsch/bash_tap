#!/usr/bin/env bash
. ../bash_tap.sh

echo foo | grep bar | cat
