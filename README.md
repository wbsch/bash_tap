## WHAT
`bash_tap.sh` is a simple Bash script to [TAP](https://testanything.org/) output converter. Any command exiting with a non-zero exit code, even if it is part | of | a | piped | command, makes `bash_tap.sh` output `not ok` TAP information.

`bash_tap.sh` tries to keep things simple. Tests look a lot like regular Bash scripts - because they are. If you are looking for a fully-featured Bash TAP producer with helper functions and a rigid formula for tests, `bash_tap.sh` is not it.

The Bash script:
```bash
#!/bin/bash
source bash_tap.sh

# This successfully finds "world" and exits with a zero exit code:
echo "Hello world" | grep "world"
# This cannot find "cookies" in the text, so it exits non-zero:
echo "Got milk?" | grep "cookies"
```

saved as `test_fail_grep.sh` leads to this output:
```console
$ ./test_fail_grep.sh
Hello world

$ ./test_fail_grep.sh -t
1..1
# This successfully finds "world" and exits with a zero exit code:
# $ echo "Hello world" | grep "world"
# >>> Hello world
# This cannot find "cookies" in the text, so it exits non-zero:
# $ echo "Got milk?" | grep "cookies"
not ok 1 - echo "Got milk?" | grep "cookies"
```

Renaming the file to have a `.t` ending makes `-t` mode the default, meaning that TAP harnesses can be run on it directly to integrate it into a pre-existing TAP test suite if needed:
```console
$ mv test_fail_grep.sh test_fail_grep.t

$ ./test_fail_grep.t
1..1
# This successfully finds "world" and exits with a zero exit code:
# $ echo "Hello world" | grep "world"
# >>> Hello world
# This cannot find "cookies" in the text, so it exits non-zero:
# $ echo "Got milk?" | grep "cookies"
not ok 1 - echo "Got milk?" | grep "cookies"

$ prove -v test_fail_grep.t
test_fail_grep.t ..
1..1
# $ echo "Hello world!" | grep "world"
# >>> Hello world!
# $ echo "Got milk?" | grep "cookies"
not ok 1 - echo "Got milk?" | grep "cookies"
Dubious, test returned 1 (wstat 256, 0x100)
Failed 1/1 subtests

Test Summary Report
-------------------
test_fail_grep.t (Wstat: 256 Tests: 1 Failed: 1)
  Failed test:  1
  Non-zero exit status: 1
Files=1, Tests=1,  0 wallclock secs ( 0.02 usr  0.01 sys +  0.00 cusr  0.03 csys =  0.06 CPU)
Result: FAIL
```

In `-t` mode, all commands are run in a temporary directory that is removed on exit. In `normal` mode, all commands are run in the current directory and no cleanup is done.



## WHY
`bash_tap.sh` is for people who have many small snippets lying around their project folder, each reproducing some kind of malfunction reported in a bug somewhere. Turning these snippets into proper TAP tests usually involves more work than one is willing or able to invest at that point in time, making those snippets linger and be forgotten.

Copy & paste is often enough to make `bash_tap.sh` run these as tests.



## HOW
All you need for writing your own tests is `bash_tap.sh`. It is important not to rename it since there is some deeply disturbing magic involved. Additionally, naming helper scripts anything but `bash_tap_HELPERNAME.sh` will lead to problems.

Included in the repo's `misc` folder is `bash_tap_tw.sh`, a file used in [Taskwarrior](http://taskwarrior.org)'s test suite. It shows how to extend `bash_tap.sh` for your own usage should plain Bash and installed commands not suffice.



## LIMITATIONS
### No multi-line Bash constructs
Good:
```bash
if [ "foo" == "bar" ]; then echo "they are the same!"; fi
```
Bad:
```bash
if [ "foo" == "bar" ]; then
    echo "they are the same!"
fi
```
While more readable, it will break when run by `bash_tap.sh`.


### One file, one test
Each file is counted as one test. Any command exiting with a non-zero exit status is output as "the failing test", even if it is part of the setup process and not an actual test at all.


### No TAP specific commands
Keeping things simple at the expense of more advanced functionality was a design decision, if "design" is what you want to call what spawned this abomination.
Other Bash TAP producers offer commands like `assertEqual [command1] [command2]` instead of relying on Bash one-liners. `bash_tap.sh` will never do that.

If you are looking for a Bash TAP producer with more features, consider evaluating (no particular order, list not exhaustive):
[bats](https://github.com/sstephenson/bats), [bash-tap](https://github.com/illusori/bash-tap), [bash-tap-functions](https://github.com/goozbach/bash-tap-functions), [sharness](http://mlafeldt.github.io/sharness/).


### Lacking portability
Unless you use nothing but Bash builtins in your tests, cross-platform portability is quite bad. Be sure to know your POSIX standards. Keep the tests simple, use a proper TAP Producer for bigger tests instead, and you will be fine.
