#!/usr/bin/env bash

function bash_tap_on_error {
    # A command in the parent script failed, interpret this as a test failure.
    # $bash_tap_line contains the last executed line, or an error.
    echo -n "$bash_tap_output"
    echo "not ok 1 - ${bash_tap_line}"
    bash_tap_clean_tmpdir
}

function run_testcase {
    # Run each line in the parent script up to the first "exit".
    bash_tap_output=""
    while IFS= read -r bash_tap_line && [ "${bash_tap_line:0:4}" != "exit" ]; do
        # Skip shebang.
        if [ "${bash_tap_line:0:2}" == "#!" ]; then
            continue
        fi

        # Avoid recursively sourcing this script, and any helper scripts.
        if [ "${bash_tap_line:0:10}" == ". bash_tap" ] || [ "${bash_tap_line:0:15}" == "source bash_tap" ]; then
            continue
        fi

        # Include comments as-is.
        if [ "${bash_tap_line:0:1}" == "#" ]; then
            bash_tap_output+="$bash_tap_line"
            bash_tap_output+=$'\n'
            continue
        fi

        # Run file line by line.
        if [ ! -z "$bash_tap_line" ] && [ "${bash_tap_line:0:2}" != "#!" ]; then
            bash_tap_output+="# $ $bash_tap_line"
            bash_tap_output+=$'\n'
            local cmd_output
            local cmd_ret
            cmd_output=$(eval "$bash_tap_line" 2>&1 | sed 's/^/# >>> /')
            cmd_ret=$?
            if [ ! -z "$cmd_output" ]; then
                bash_tap_output+="$cmd_output"
                bash_tap_output+=$'\n'
            fi
            if [ "$cmd_ret" -ne 0 ]; then
                exit $cmd_ret
            fi
        fi
    done <"$org_script"
}

function bash_tap_clean_tmpdir {
    if [ ! -z "$bash_tap_tmpdir" ] && [ -d "$bash_tap_tmpdir" ]; then
        cd "$org_pwd"
        rm -rf "$bash_tap_tmpdir"
    fi
}

function get_absolute_path {
    # NOTE: No actual thought put into this. Might break. Horribly.
    # Using this instead of readlink/realpath for OSX compatibility.
    echo $(cd "$(dirname "$1")" && pwd)/$(basename "$1")
}


org_pwd=$(pwd)
org_script=$(get_absolute_path "$0")

if [ "${0:(-2)}" == ".t" ] || [ "$1" == "-t" ]; then
    # Make sure any failing commands are caught.
    set -e
    set -o pipefail

    # TAP header. Hardcoded number of tests, 1.
    # We could count each executed line as a test instead...
    echo "1..1"

    # Output TAP failure on early exit.
    trap bash_tap_on_error EXIT

    # The different calls to mktemp are necessary for OSX compatibility.
    bash_tap_tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'bash_tap')
    if [ ! -z "$bash_tap_tmpdir" ]; then
        cd "$bash_tap_tmpdir"
    else
        bash_tap_line="Unable to create temporary directory."
        exit 1
    fi

    # Scripts sourced before bash_tap.sh may declare this function.
    if declare -f bash_tap_setup >/dev/null; then
        bash_tap_setup
    fi

    # Run test file interpreting failing commands as a test failure.
    run_testcase && echo "ok 1"

    # Since we're in a sourced file and just ran the parent script,
    # exit without running it a second time.
    trap - EXIT
    bash_tap_clean_tmpdir
    exit
else
    if declare -f bash_tap_setup >/dev/null; then
        bash_tap_setup
    fi
fi
