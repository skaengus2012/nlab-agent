#!/usr/bin/env bash
# Tests for .githooks/commit-msg. Usage: bash tests/commit-msg.test.sh
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
HOOK="$REPO_ROOT/.githooks/commit-msg"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Isolate from the user's git configuration.
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_NOSYSTEM=1

pass=0
fail=0

run_hook() {
    local msg_file="$TMP/msg"
    printf '%b' "$1" > "$msg_file"
    "$HOOK" "$msg_file" >/dev/null 2>&1
}

expect_pass() {
    if run_hook "$2"; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1)); echo "FAIL (should pass): $1"
    fi
}

expect_block() {
    if run_hook "$2"; then
        fail=$((fail + 1)); echo "FAIL (should block): $1"
    else
        pass=$((pass + 1))
    fi
}

# Messages that must pass
expect_pass "Implement with issue number" "Implement #12 - Add deep-research skill\n"
expect_pass "Chore without issue number" "Chore N/A - Update README documentation\n"
expect_pass "Fix with issue number" "Fix #5 - Correct typo in setup.sh path\n"
expect_pass "Merge commit" "Merge branch 'feature/x' into main\n"
expect_pass "Revert commit" "Revert \"Implement #1 - x\"\n"
expect_pass "fixup commit" "fixup! Implement #1 - x\n"
expect_pass "squash commit" "squash! Implement #1 - x\n"
expect_pass "Trailer after body" "Implement #3 - Add hook\n\nbody text\n\nCo-Authored-By: A <a@example.com>\n"
expect_pass "Leading comment lines" "# Please enter the commit message\n# Lines starting with # are ignored\nFix #7 - Handle empty case\n"
expect_pass "Leading blank lines" "\n\nChore #8 - Tidy up\n"

# Messages that must be blocked
expect_block "Missing issue and description" "Fix N/A\n"
expect_block "Issue number without #" "Fix 12 - x\n"
expect_block "Lowercase category" "implement #1 - x\n"
expect_block "Empty description" "Fix #1 - \n"
expect_block "Whitespace-only description" "Fix #1 -    \n"
expect_block "Unknown category" "Update #1 - x\n"
expect_block "Missing separator" "Fix #1 x\n"
expect_block "Comment-only message" "# only comments\n"
expect_block "Empty message" ""

# Integration: a real commit in a temporary repository
repo="$TMP/repo"
git init -q "$repo"
git -C "$repo" config user.name "Test"
git -C "$repo" config user.email "test@example.com"
git -C "$repo" config commit.gpgsign false
git -C "$repo" config core.hooksPath "$REPO_ROOT/.githooks"

if git -C "$repo" commit -q --allow-empty -m "bad message" >/dev/null 2>&1; then
    fail=$((fail + 1)); echo "FAIL (integration): violating commit succeeded"
else
    pass=$((pass + 1))
fi

if git -C "$repo" commit -q --allow-empty -m "Chore N/A - integration check" >/dev/null 2>&1; then
    pass=$((pass + 1))
else
    fail=$((fail + 1)); echo "FAIL (integration): valid commit was rejected"
fi

echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
