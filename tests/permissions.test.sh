#!/usr/bin/env bash
# Checks the blocks in PERMISSIONS.md: no prompt-required command may be covered by an auto-allow entry.
# Usage: bash tests/permissions.test.sh
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

python3 - "$REPO_ROOT" <<'PY'
import re, sys, os

root = sys.argv[1]
failures = []

def blocks(text):
    return {m.group(1): [l.strip() for l in m.group(2).strip().split("\n")
                         if l.strip() and not l.strip().startswith("#")]
            for m in re.finditer(r"```permissions:([\w-]+)\n(.*?)\n```", text, re.DOTALL)}

perm = blocks(open(os.path.join(root, "PERMISSIONS.md"), encoding="utf-8").read())
for name in ("auto-allow", "prompt-required"):
    if name not in perm:
        failures.append(f"PERMISSIONS.md has no permissions:{name} block")

prompt_required = perm.get("prompt-required", [])
auto_allow = perm.get("auto-allow", [])

for p in sorted(prompt_required):
    for a in auto_allow:
        if p == a or p.startswith(a + " "):
            failures.append(f"prompt-required '{p}' is covered by auto-allow '{a}'")

for f in failures:
    print("FAIL " + f)
print("failed: %d" % len(failures))
sys.exit(1 if failures else 0)
PY
