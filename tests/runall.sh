#!/usr/bin/env bash

rc=0
count=0

echo -n "1.."
ls -l test_*.t | wc -l

for t in test_*.t; do
    if [ ! -x "$t" ]; then
        # Skip non-executable tests
        continue
    fi
    count=$((count+1))
    ./$t &> _testout
    t_exitcode=$?
    if [[ "$t" =~ ^test_fail_ ]]; then
        # Failing test expected
        if [ "$t_exitcode" == "0" ]; then
            echo "not ok $count - $t ran successfully, but shouldn't have."
            rc=1
        elif ! grep '^not ok' _testout &>/dev/null; then
            echo "not ok $count - $t failed, but didn't output TAP failure."
            rc=1
        else
            echo "ok $count - $t"
        fi
    else
        # Regular test expected
        if [ "$t_exitcode" != "0" ]; then
            echo "not ok $count - $t failed, but shouldn't have."
            rc=1
        elif ! grep '^ok' _testout &>/dev/null; then
            echo "not ok $count - $t ran successfully, but didn't output TAP success."
            rc=1
        else
            echo "ok $count - $t"
        fi
    fi
done

rm _testout

exit $rc

