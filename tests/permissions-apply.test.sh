#!/usr/bin/env bash
# Tests platforms/lib/permissions.py and its use by platforms/{claude,codex}/setup.sh.
# Uses temporary directories only; the real ~/.claude and ~/.codex are never touched.
# Usage: bash tests/permissions-apply.test.sh
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TOOL="$REPO_ROOT/platforms/lib/permissions.py"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0
ok()  { pass=$((pass + 1)); }
bad() { fail=$((fail + 1)); echo "FAIL: $1"; }
check() { if "${@:2}" >/dev/null 2>&1; then ok; else bad "$1"; fi; }

# A small fixture so the unit tests do not depend on the real lists.
cat > "$TMP/PERMISSIONS.md" <<'EOF'
```permissions:auto-allow
git status
gh pr view
```

```permissions:prompt-required
git push
gh pr merge
```
EOF

# json_has <file> <python expression over d>: succeeds when the expression is true
json_has() { python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if eval(sys.argv[2]) else 1)' "$1" "$2"; }

# 1. claude: creates the file and writes both forms of every rule
S="$TMP/new/settings.json"
python3 "$TOOL" claude "$S" "$TMP/PERMISSIONS.md" >/dev/null 2>&1
check "claude: file was not created" test -f "$S"
check "claude: allow lacks both forms" json_has "$S" "{'Bash(git status)','Bash(git status *)','Bash(gh pr view)','Bash(gh pr view *)'} <= set(d['permissions']['allow'])"
check "claude: ask lacks both forms" json_has "$S" "{'Bash(git push)','Bash(git push *)','Bash(gh pr merge)','Bash(gh pr merge *)'} <= set(d['permissions']['ask'])"

# 2. claude: running again does not change the file
cp "$S" "$TMP/before.json"
python3 "$TOOL" claude "$S" "$TMP/PERMISSIONS.md" >/dev/null 2>&1
check "claude: second run changed the file" cmp -s "$S" "$TMP/before.json"

# 3. claude: existing keys and rules are kept
S="$TMP/existing/settings.json"; mkdir -p "$(dirname "$S")"
cat > "$S" <<'EOF'
{
  "theme": "dark",
  "permissions": {
    "allow": ["Bash(npm test)"],
    "deny": ["Read(./.env)"],
    "defaultMode": "default"
  },
  "hooks": {"Stop": []}
}
EOF
python3 "$TOOL" claude "$S" "$TMP/PERMISSIONS.md" >/dev/null 2>&1
check "claude: unrelated keys were lost" json_has "$S" "d['theme']=='dark' and d['hooks']=={'Stop': []} and d['permissions']['defaultMode']=='default'"
check "claude: existing rules were lost" json_has "$S" "'Bash(npm test)' in d['permissions']['allow'] and d['permissions']['deny']==['Read(./.env)']"
check "claude: new rules were not added" json_has "$S" "'Bash(git status)' in d['permissions']['allow'] and 'Bash(git push)' in d['permissions']['ask']"
check "claude: a rule appears more than once" json_has "$S" "len(d['permissions']['allow'])==len(set(d['permissions']['allow']))"

# 4. claude: an invalid file is left untouched and reported
S="$TMP/broken/settings.json"; mkdir -p "$(dirname "$S")"
printf '{ "permissions": { // comment\n' > "$S"; cp "$S" "$TMP/broken.before"
python3 "$TOOL" claude "$S" "$TMP/PERMISSIONS.md" >/dev/null 2>&1; rc=$?
[ "$rc" -ne 0 ] && ok || bad "claude: invalid JSON exited 0"
check "claude: invalid JSON was modified" cmp -s "$S" "$TMP/broken.before"

# 5. codex: rules file has one rule per command with the right decision
R="$TMP/codex/rules/nlab-agent.rules"
python3 "$TOOL" codex "$R" "$TMP/PERMISSIONS.md" >/dev/null 2>&1
check "codex: rules file was not created" test -f "$R"
check "codex: allow rule missing" grep -q 'pattern=\["git", "status"\], decision="allow"' "$R"
check "codex: prompt rule missing" grep -q 'pattern=\["git", "push"\], decision="prompt"' "$R"

# 6. codex: rewriting gives the same file even when the old one had other content
printf 'junk\n' > "$R"; python3 "$TOOL" codex "$R" "$TMP/PERMISSIONS.md" >/dev/null 2>&1
cp "$R" "$TMP/rules.a"; python3 "$TOOL" codex "$R" "$TMP/PERMISSIONS.md" >/dev/null 2>&1
check "codex: rewrite is not stable" cmp -s "$R" "$TMP/rules.a"
check "codex: old content was kept" bash -c "! grep -q junk '$R'"

# 7. codex: the real CLI accepts the rules and reports the expected decisions
if command -v codex >/dev/null 2>&1; then
    decision() { codex execpolicy check --rules "$R" "$@" 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin).get("decision",""))'; }
    [ "$(decision git status)" = "allow" ] && ok || bad "codex CLI: git status is not allow"
    [ "$(decision git push origin main)" = "prompt" ] && ok || bad "codex CLI: git push is not prompt"
    [ "$(decision gh pr merge 1)" = "prompt" ] && ok || bad "codex CLI: gh pr merge is not prompt"
else
    echo "skip: codex CLI not installed, execpolicy checks not run"
fi

# 8. The real PERMISSIONS.md gives a working Codex rules file and Claude settings
R2="$TMP/real/nlab-agent.rules"; S2="$TMP/real/settings.json"
python3 "$TOOL" codex "$R2" "$REPO_ROOT/PERMISSIONS.md" >/dev/null 2>&1 && ok || bad "real PERMISSIONS.md: codex conversion failed"
python3 "$TOOL" claude "$S2" "$REPO_ROOT/PERMISSIONS.md" >/dev/null 2>&1 && ok || bad "real PERMISSIONS.md: claude conversion failed"
check "real: git push is not asked in Claude settings" json_has "$S2" "'Bash(git push)' in d['permissions']['ask'] and 'Bash(git push *)' in d['permissions']['ask']"
check "real: git fetch is not allowed in Claude settings" json_has "$S2" "'Bash(git fetch *)' in d['permissions']['allow']"
check "real: ask entries are not also allowed" json_has "$S2" "not (set(d['permissions']['ask']) & set(d['permissions']['allow']))"

# 9. setup scripts apply the rules under a redirected home, and leave the real home alone
for p in claude codex; do
    d="$TMP/setup-$p"; mkdir -p "$d/home"
    HOME="$d/home" CLAUDE_HOME="$d/claude" CODEX_HOME="$d/codex" bash "$REPO_ROOT/platforms/$p/setup.sh" --global >"$d/out.txt" 2>&1
    [ "$?" = "0" ] && ok || bad "$p setup exited non-zero"
done
check "setup claude: settings.json was not written" json_has "$TMP/setup-claude/claude/settings.json" "'Bash(git push *)' in d['permissions']['ask']"
check "setup codex: rules file was not written" test -s "$TMP/setup-codex/codex/rules/nlab-agent.rules"
check "setup claude: output does not name the file" grep -q "settings.json" "$TMP/setup-claude/out.txt"
check "setup codex: output does not name the file" grep -q "nlab-agent.rules" "$TMP/setup-codex/out.txt"

# 10. a broken settings.json does not stop setup from finishing
d="$TMP/setup-broken"; mkdir -p "$d/home" "$d/claude"; printf '{ nope\n' > "$d/claude/settings.json"
HOME="$d/home" CLAUDE_HOME="$d/claude" bash "$REPO_ROOT/platforms/claude/setup.sh" --global >"$d/out.txt" 2>&1
[ "$?" = "0" ] && ok || bad "setup claude failed on a broken settings.json"
check "setup claude: no warning for a broken settings.json" grep -qi "warning" "$d/out.txt"
check "setup claude: skills were not linked after a broken settings.json" test -e "$d/claude/skills/create-plans"

echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
