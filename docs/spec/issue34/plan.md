# Plan: [Task] Audit scripts for macOS-specific code and make them cross-platform (#34)

- Issue: https://github.com/skaengus2012/nlab-agent/issues/34
- Requirements: docs/spec/issue34/requirements.md
- Created: 2026-11-17
- Last Updated: 2026-11-17

## Context/Goals
The repository's scripts must not be macOS-only. Audit the sh and Python scripts, record the result, fix anything macOS-specific, and back the result with a static audit and a macOS test run.

## Requirements
- FR-1: Audit every sh and Python script under `platforms/`, `skills/`, and `tests/`.
- FR-2: Record the list of macOS-specific code found (an explicit "0 found" counts).
- FR-3: Fix every found item so it works on macOS and Linux.
- NFR-1: Targets are macOS and Linux (Windows via WSL). Native Windows is out of scope.
- NFR-2: Prefer POSIX-common syntax; OS branching only when unavoidable, with the reason in a comment.
- Acceptance: the static audit result is recorded, and `tests/permissions-apply.test.sh` passes on macOS. Linux execution is not required for now (user decision, 2026-11-17).

## Architecture/Design
No design change is planned. The work is an audit plus evidence.
- An earlier line-by-line read (Opus review) found no macOS-specific code, so the expected outcome is "0 found, no code change". The audit in Task 1 is run again here so the result is recorded from this branch.
- If an item is found, the fix replaces it with a POSIX-common form. No per-OS branching.
- The found-code list goes in the Impact section of `requirements.md` and in the PR description. No separate document.
- Verification is static only: the code audit plus a macOS test run. No Linux execution for now.

## Tasks
1. Audit all sh/py files under `platforms/`, `skills/`, and `tests/` for macOS-specific code, line by line.
   - Check for: `sed -i ''`, `open`, `pbcopy`/`pbpaste`, `readlink -f`, `stat -f`, `date -j`/`date -v`, `osascript`, `brew`, BSD-only options of `cp`/`mktemp`/`xargs`/`find`/`ln`, bash 4+ features (macOS ships bash 3.2), `/Users/` paths, and `#!/bin/bash` versus `#!/usr/bin/env bash`.
   - **Verify**: a written list (items with file:line, or an explicit "0 found") exists in the Impact section of `requirements.md`.
2. Fix each found item with a POSIX-common form (skip if Task 1 found none).
   - **Verify**: `bash tests/permissions-apply.test.sh` passes on macOS; re-run the Task 1 patterns and get no hits.
~~3. Run `tests/permissions-apply.test.sh` on Linux.~~ (Dropped: static verification on macOS is enough for now; no container runtime is available here.)
5. Change the six `platforms/*/{setup,link_skills}.sh` shebangs from `#!/bin/bash` to `#!/usr/bin/env bash` (user decision; adds no OS branching).
   - **Verify**: `head -n1` of every script shows `#!/usr/bin/env bash`; `bash tests/permissions-apply.test.sh` has 0 failures; each `setup.sh --global` runs directly (via its shebang) against temporary directories and exits 0.
4. Update `requirements.md` (Impact, Acceptance Criteria checkboxes, Change History) with the audit result.
   - **Verify**: the checkboxes match the evidence from Tasks 1 and 2.

## Verification
- Audit list recorded (Task 1), including an explicit "0 found" if applicable.
- macOS test run: `bash tests/permissions-apply.test.sh` has 0 failures.
- No new OS-branching code: `git diff main -- platforms tests` has no `uname`/OS conditionals (or each has a reason comment).

---

## Change History
| Date | Change | Source |
|------|--------|--------|
| 2026-11-17 | Initial draft | requirements.md |
| 2026-11-17 | Task 3 (Linux run) dropped; verification narrowed to the static audit and a macOS test run. | User decision in chat |
| 2026-11-17 | Task 5 added: unify shebangs to `#!/usr/bin/env bash`. | User decision in chat |
