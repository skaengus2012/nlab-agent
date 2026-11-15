#!/usr/bin/env bash
# Tests enable_commit_hook in platforms/*/setup.sh using temporary copies only.
# Usage: bash tests/setup-hook.test.sh
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL=/dev/null

pass=0
fail=0
ok()  { pass=$((pass + 1)); }
bad() { fail=$((fail + 1)); echo "FAIL: $1"; }

# new_repo <name> [git|nogit]: a copy of this repository without its .git directory
new_repo() {
    local dir="$TMP/$1"
    mkdir -p "$dir"
    rsync -a --exclude .git "$REPO_ROOT/" "$dir/"
    [ "${2:-git}" = "git" ] && git init -q "$dir"
    echo "$dir"
}

# run_setup <platform> <repo>: runs setup with every home directory redirected into TMP
run_setup() {
    HOME="$TMP/home" CLAUDE_HOME="$TMP/claude" bash "$2/platforms/$1/setup.sh" --global > "$TMP/out.txt" 2>&1
    echo $? > "$TMP/rc.txt"
}
rc() { cat "$TMP/rc.txt"; }
hooks_path() { git -C "$1" config --local --get core.hooksPath || true; }

# 1. Every platform enables the hook in a plain git repository
for p in claude codex antigravity; do
    r="$(new_repo "plain-$p")"
    run_setup "$p" "$r"
    [ "$(hooks_path "$r")" = ".githooks" ] && ok || bad "$p did not enable the hook"
    [ "$(rc)" = "0" ] || bad "$p exited with $(rc)"
done

# 2. Running twice keeps one setting and succeeds
r="$(new_repo twice)"; run_setup claude "$r"; run_setup claude "$r"
[ "$(hooks_path "$r")" = ".githooks" ] && [ "$(rc)" = "0" ] && ok || bad "second run changed the result"

# 3. A copy that is not a git repository is skipped without failing
r="$(new_repo nogit nogit)"; run_setup claude "$r"
[ "$(rc)" = "0" ] && grep -q "skip" "$TMP/out.txt" && ok || bad "non-git copy was not skipped cleanly"

# 4. An existing local hooksPath is left unchanged
r="$(new_repo localpath)"; git -C "$r" config core.hooksPath /custom/hooks; run_setup claude "$r"
[ "$(hooks_path "$r")" = "/custom/hooks" ] && ok || bad "local hooksPath was overwritten"

# 5. An existing executable hook in .git/hooks is not silently disabled
r="$(new_repo userhook)"
printf '#!/bin/sh\nexit 0\n' > "$r/.git/hooks/pre-commit"; chmod +x "$r/.git/hooks/pre-commit"
run_setup claude "$r"
[ -z "$(hooks_path "$r")" ] && grep -qi "warning" "$TMP/out.txt" && [ "$(rc)" = "0" ] && ok || bad "existing .git/hooks hook was disabled or not reported"

# 6. Sample hooks only do not block enabling
r="$(new_repo samples)"; run_setup claude "$r"
[ "$(hooks_path "$r")" = ".githooks" ] && ok || bad "sample hooks blocked enabling"

# 7. A global core.hooksPath is not overridden
r="$(new_repo globalpath)"
printf '[core]\n\thooksPath = /global/hooks\n' > "$TMP/gitconfig-global"
GIT_CONFIG_GLOBAL="$TMP/gitconfig-global" run_setup claude "$r"
[ -z "$(hooks_path "$r")" ] && grep -qi "warning" "$TMP/out.txt" && [ "$(rc)" = "0" ] && ok || bad "global hooksPath was overridden or not reported"

# 8. A missing hook file is skipped instead of reporting success
r="$(new_repo nohookfile)"; rm -f "$r/.githooks/commit-msg"; run_setup claude "$r"
[ -z "$(hooks_path "$r")" ] && ! grep -q "Enabled" "$TMP/out.txt" && [ "$(rc)" = "0" ] && ok || bad "missing hook file reported as enabled"

echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
