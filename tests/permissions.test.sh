#!/usr/bin/env bash
# Checks that .claude/settings.json stays consistent with PERMISSIONS.md.
# Usage: bash tests/permissions.test.sh
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

python3 - "$REPO_ROOT" <<'PY'
import json, re, sys, os

root = sys.argv[1]
failures = []

def blocks(text):
    return {m.group(1): [l.strip() for l in m.group(2).strip().split("\n")
                         if l.strip() and not l.strip().startswith("#")]
            for m in re.finditer(r"```permissions:([\w-]+)\n(.*?)\n```", text, re.DOTALL)}

perm = blocks(open(os.path.join(root, "PERMISSIONS.md"), encoding="utf-8").read())
for name in ("auto-allow", "prompt-required", "claude-ask"):
    if name not in perm:
        failures.append(f"PERMISSIONS.md has no permissions:{name} block")

settings_path = os.path.join(root, ".claude", "settings.json")
try:
    settings = json.load(open(settings_path, encoding="utf-8"))
except Exception as e:
    settings = {}
    failures.append(f".claude/settings.json is missing or invalid: {e}")

def normalize(rule):
    m = re.fullmatch(r"Bash\((.*?)(?: \*)?\)", rule)
    return m.group(1) if m else rule

perms = settings.get("permissions", {})
ask = {normalize(r) for r in perms.get("ask", [])}
claude_ask = set(perm.get("claude-ask", []))
prompt_required = set(perm.get("prompt-required", []))
auto_allow = perm.get("auto-allow", [])

# (1) settings ask == claude-ask block
if ask != claude_ask:
    failures.append(f"(1) permissions.ask {sorted(ask)} != claude-ask block {sorted(claude_ask)}")

# (2) claude-ask is a subset of prompt-required
if not claude_ask <= prompt_required:
    failures.append(f"(2) claude-ask has entries outside prompt-required: {sorted(claude_ask - prompt_required)}")

# (3) no prompt-required entry is covered by an auto-allow entry
for p in sorted(prompt_required):
    for a in auto_allow:
        if p == a or p.startswith(a + " "):
            failures.append(f"(3) prompt-required '{p}' is covered by auto-allow '{a}'")

# (4) the commit hook bypasses are denied
expected_deny = {
    "Bash(git *--no-verify*)",
    "Bash(git commit -n*)",
    "Bash(git *core.hooksPath*)",
    "Bash(git commit * -n *)",
    "Bash(git commit * -n)",
}
missing = expected_deny - set(perms.get("deny", []))
if missing:
    failures.append(f"(4) permissions.deny is missing {sorted(missing)}")

for f in failures:
    print("FAIL " + f)
print("failed: %d" % len(failures))
sys.exit(1 if failures else 0)
PY
