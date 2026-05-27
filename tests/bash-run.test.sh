#!/usr/bin/env bash
#
# Tests for bin/bash-run.
# Run: ./tests/bash-run.test.sh
#

set -u

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/bin/bash-run"

pass=0
fail=0

assert_eq() {
    local name="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        pass=$((pass + 1))
        printf '  ok   %s\n' "$name"
    else
        fail=$((fail + 1))
        printf '  FAIL %s\n' "$name"
        printf '       expected: %q\n' "$expected"
        printf '       actual:   %q\n' "$actual"
    fi
}

run_case() {
    printf '\n# %s\n' "$1"
}

# ---

run_case "no args prints usage and exits 1"
output=$("$SCRIPT" 2>&1); status=$?
assert_eq "exit code" "1" "$status"
assert_eq "usage line" "Usage: bash-run content [<arg>...]" "$(printf '%s\n' "$output" | head -n1)"

run_case "--help exits 0"
output=$("$SCRIPT" --help 2>&1); status=$?
assert_eq "exit code" "0" "$status"

run_case "-h exits 0"
output=$("$SCRIPT" -h 2>&1); status=$?
assert_eq "exit code" "0" "$status"

run_case "runs script under bash"
output=$("$SCRIPT" 'echo "$BASH_VERSION"' | cut -d. -f1)
assert_eq "BASH_VERSION major is numeric" "1" "$([[ "$output" =~ ^[0-9]+$ ]] && echo 1 || echo 0)"

run_case "passes positional args correctly"
output=$("$SCRIPT" 'printf "[%s]" "$@"' "hello world" haha plop)
assert_eq "arg count + values" "[hello world][haha][plop]" "$output"

run_case "passes \$# correctly"
output=$("$SCRIPT" 'echo $#' a b c d)
assert_eq "\$# is 4" "4" "$output"

run_case "stdin is inherited"
output=$(echo "piped data" | "$SCRIPT" 'cat')
assert_eq "cat sees stdin" "piped data" "$output"

run_case "inner exit code propagates"
"$SCRIPT" 'exit 42'; status=$?
assert_eq "exit code" "42" "$status"

run_case "inner failure propagates with errexit-like script"
"$SCRIPT" 'false' 2>/dev/null; status=$?
assert_eq "false exits 1" "1" "$status"

run_case "\$0 inside the script is bash-run"
output=$("$SCRIPT" 'echo "$0"')
assert_eq "\$0" "bash-run" "$output"

# ---

printf '\n%d passed, %d failed\n' "$pass" "$fail"
exit "$fail"
