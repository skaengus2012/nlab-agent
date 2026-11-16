# Requirements Analysis: [Task] Audit scripts for macOS-specific code and make them cross-platform (#34)

- Issue: https://github.com/skaengus2012/nlab-agent/issues/34
- Parent issue: None
- Labels: skills
- Created: 2026-11-16
- Last Updated: 2026-11-17
- Analysis Baseline: 2026-11-16T16:41:00Z

## Background and Problem
During the review of #30, Claude's review pointed out that some of the code is macOS-only. Shell scripts, Python, and other code in this repository may have been written with macOS in mind, and no one has checked how much of it depends on macOS-specific behavior.

## Goals
The repository's scripts must not be macOS-only. Find macOS-specific code in the sh and Python scripts, list it, and fix it so the scripts work across platforms.

## Scope
### In Scope
- sh and Python scripts under `platforms/` and `skills/` (issue body).
- `tests/` scripts, because the setup scripts they verify are in scope (decided with Opus review at the user's request, 2026-11-17).
- Producing a list of every macOS-specific piece of code found.
- Fixing all of the found code to work on macOS and Linux (including WSL).

### Out of Scope
- Native Windows (PowerShell/cmd). A separate issue if needed.
- `docs/spec/issue27/evals/` (one-off experiment output of #27).
- Command examples inside Markdown docs and data files (`.json`, `.tsv`).
- `skills/.DS_Store`: not tracked by git and already ignored by `.gitignore`.

## Functional Requirements
| ID | Requirement | Source |
|----|-------------|--------|
| FR-1 | Audit every sh and Python script under `platforms/`, `skills/`, and `tests/` for macOS-specific code (e.g. `sed -i ''`, `open`, `pbcopy`, BSD-only command options). | Body; scope decision in chat (2026-11-17) |
| FR-2 | Produce a list of every macOS-specific piece of code that is found. If none is found, state that explicitly. | Body |
| FR-3 | Fix every listed piece of macOS-specific code so that it works on macOS and Linux. | Body |
| ~~FR-4~~ | (Dropped: whole-repo audit was over-scoped; the user's intent is only "not macOS-only". `tests/` was added to FR-1 instead.) | User decision in chat (2026-11-17) |

## Non-Functional Requirements
| ID | Requirement | Source |
|----|-------------|--------|
| NFR-1 | The scripts must work across platforms (not only macOS). Supported targets are macOS and Linux; Windows is supported through WSL, which follows the Linux path. | Body; user decision in chat (2026-11-17) |
| NFR-2 | Prefer POSIX-common syntax and options. Branching per OS is allowed only when unavoidable, with the reason noted in a comment. | User decision in chat (2026-11-17), softened from "no OS-branching code" |
| ~~NFR-3~~ | (Dropped: native Windows is out of scope, so the symlink privilege question no longer applies.) | User decision in chat (2026-11-17) |

## Acceptance Criteria
- [ ] Every sh and Python script under `platforms/`, `skills/`, and `tests/` has been audited, and the result list exists (an explicit "0 found" counts).
- [ ] Every found item has been fixed to work on macOS and Linux.
- [ ] `tests/permissions-apply.test.sh` passes fully on macOS. Linux execution is not required for now (static verification only).

## Impact
Confirmed from the code (as of this analysis):
- Scripts in scope: `platforms/{claude,codex,antigravity}/{setup,link_skills}.sh`, `platforms/lib/apply_permissions.sh`, `platforms/lib/permissions.py`, and `tests/permissions-apply.test.sh`.
- `skills/` contains no sh or Python files.
- A line-by-line read of the tracked sh/py files (including the out-of-scope `docs/spec/issue27/evals/` ones) found **no macOS-specific code**. No use of `sed -i ''`, the `open` command, `pbcopy`, `readlink -f`, `stat -f`, `date -j`, or `osascript`. The commands used (`ln -sf`/`ln -sfn`, `mktemp -d`, `pwd -P`, `sed -n`, `seq`, `cmp -s`, `grep -q`) behave the same on BSD and GNU. Python `open()` is the built-in, and `os.replace` and `tempfile` are OS-independent.
- Minor note, not OS-related: `codex` and `antigravity` `link_skills.sh` use `ln -sf src dir/`, while `claude` uses `ln -sfn src dir/name`. Out of scope for this issue.
- The result is therefore likely "audit complete, no fix needed", backed by the static audit and the macOS test run.

## Open Questions
- Where should the found-code list live: the Impact section of this report or the PR description? (Proposed: Impact section and/or PR description; no separate document, since the result is small.)

## Conflicts and Notes
No comments exist on the issue, so there is no conflict between the body and comments. The user said that the real intent is only to avoid a macOS-only repository, so the earlier native-Windows, no-OS-branching, and whole-repo expansions were rolled back after an Opus review. The issue originates from a review comment on #30 (the review content itself was not read).

---

## Change History
| Date | Change | Source |
|------|--------|--------|
| 2026-11-17 | Initial draft | Body |
| 2026-11-17 | Resolved open question: "cross-platform" includes Windows (NFR-1 updated). Added follow-up question on which Windows environments. | User decision in chat |
| 2026-11-17 | Standard Windows must be supported (NFR-1) and OS-branching code is not allowed (NFR-2 added, acceptance criteria updated). Replaced the Windows-environment question with two design/privilege questions. | User decision in chat |
| 2026-11-17 | Resolved open question: symlink privilege requirement on native Windows is acceptable (NFR-3 added). | User decision in chat |
| 2026-11-17 | Audit scope expanded to other code in the repository (FR-4 added, scope and acceptance criteria updated); found `tests/` and `docs/spec/issue27/evals/` scripts missing from the earlier list. Replaced the scope question with a narrower one on what "other code" covers. | User decision in chat |
| 2026-11-17 | Rolled back over-scoping after the user said the intent is only "not macOS-only" and delegated decisions to an Opus review: native Windows and NFR-3 dropped, NFR-2 softened, FR-4 dropped (`tests/` added to FR-1), `.DS_Store` question closed, verification set to a Linux container test run. Impact updated with the line-by-line audit result (0 macOS-specific code found). | User decision in chat; Opus review |
| 2026-11-17 | Verification narrowed to the static code audit plus a macOS test run; the Linux container acceptance criterion was removed for now. | User decision in chat |
