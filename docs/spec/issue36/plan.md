# Plan: [Feature] Add skill for resolving merge conflicts between branches (#36)

- Issue: https://github.com/skaengus2012/nlab-agent/issues/36
- Requirements: docs/spec/issue36/requirements.md
- Created: 2026-11-23
- Last Updated: 2026-11-23

## Context/Goals
Add a shared skill `resolve-merge-conflicts` that merges a source branch into a target branch on a newly created branch, commits the conflicted state first, then resolves conflicts with the user's confirmation and commits the resolution separately so a human can review it as a diff.

## Requirements
Derived from `requirements.md` (IDs refer to it; FR-3 is dropped).
- FR-1, FR-2, FR-4, FR-5, FR-6: a merge-only conflict resolution skill that analyzes, proposes, and applies after confirmation.
- FR-7, FR-8, FR-14, FR-15, FR-16: step-by-step branch input, new branch with the timestamped name, preconditions, worktree-safe branch creation.
- FR-9, FR-10, FR-17, FR-18, FR-19: marker commit first, resolution commit second, hook/markerless/rerere/leftover-marker handling.
- FR-11, FR-12: ambiguous conflicts get two higher-tier model review rounds before asking the user; per-file confirmation with a final diff approval.
- FR-13: skill named `resolve-merge-conflicts`, in `skills/`, listed in `AGENTS.md` under "Quality & Workflow".
- NFR-1: no resolution commit before explicit user confirmation.

## Architecture/Design
- **Deliverable**: one file, `skills/resolve-merge-conflicts/SKILL.md` (frontmatter `name`, `description`), following the style of existing skills (e.g. `skills/requesting-code-review/SKILL.md`). No scripts unless a step proves too error-prone in prose.
- **Agent-neutral**: git CLI commands plus plain-text single questions (like `create-gh-issue`); no Claude-only tools. The higher-tier review is described as "delegate to a higher-tier model/subagent where available" (`AGENTS.md` `model_resolution`: Opus-tier for strategic work).
- **Flow** (the skill body follows this order):
  1. Preconditions: clean tree, no in-progress merge/rebase/cherry-pick (`git rev-parse --git-path`); stop otherwise, never auto-stash; remember the original branch.
  2. Ask source branch, then target branch (one question at a time); ask local vs `origin/` base and whether to fetch.
  3. Create `merge/<src>-into-<tgt>-<UTC timestamp>` from the target ref with `git switch -c <new> <target>`.
  4. `git merge --no-ff --no-commit <source>`; if no conflicts, commit as is and stop. Cancelling (`git merge --abort`, switch back) is possible until step 6.
  5. Marker-less conflicts (binary, modify/delete, rename, submodule, mode, LFS): always ask; record the decision. The remaining unmerged files are the "marker files"; if none remain, commit the merge and stop.
  6. Marker commit: stage the marker files and commit the conflicted state (hook failure → ask before `--no-verify`); warn it is a broken-build commit; record the hash.
  7. Per marker file: analyze, propose a resolution with a confidence level; low confidence → two independent higher-tier review rounds (a rejection or an alternative counts as disagreement) → still ambiguous → ask the user.
  8. Per-file confirmation, apply to the working tree, show `git diff HEAD` against the marker commit, verify with a marker `git grep` over all marker files (`git diff --check` only for whitespace), get final approval.
  9. Resolution commit (separate). Do not push or integrate; mention squash as an integration option.
- Review round semantics: two independent reviews; disagreement, rejection, or doubt means ambiguous and goes to the user (no further rounds).

## Tasks
1. Create `skills/resolve-merge-conflicts/SKILL.md` with frontmatter, When to Use, and the overall flow outline (merge only; rebase and other operations stated as out of scope).
   - **Verify**: `head -5` shows valid frontmatter with `name: resolve-merge-conflicts`; the flow section lists steps 1-9 above.
2. Write the setup steps: preconditions, step-by-step branch questions, base ref/fetch question, and branch naming rules (FR-7, FR-8, FR-14, FR-15, FR-16).
   - **Verify**: a documented `date -u +%Y%m%dT%H%M%SZ` command works on this machine; the sanitization example (`feature/issue36` → `feature-issue36`) passes `git check-ref-format --branch`.
3. Write the merge and marker-commit steps, including no-conflict skip, hook handling, and broken-build warning (FR-9, FR-17, FR-19 rerere note).
   - **Verify**: dry-run the documented commands in a temp repo (Task 8); the marker commit is created and `git log` shows it.
4. Write the analysis/proposal step with confidence levels and the two-round higher-tier review, plus the rule that disagreement or remaining doubt becomes a question to the user (FR-4, FR-5, FR-11, FR-12).
   - **Verify**: the text defines confidence levels, the two rounds, and the escalation condition unambiguously (re-read against FR-11).
5. Write the marker-less conflict handling (FR-18).
   - **Verify**: dry-run a modify/delete conflict in a temp repo; the documented commands let the user pick and the decision appears in the commit message.
6. Write the confirmation and resolution commit steps: per-file confirmation, final diff approval, `git diff --check` + marker grep (including `|||||||`), separate resolution commit, no push (FR-6, FR-10, FR-12, FR-19, NFR-1).
   - **Verify**: dry-run in a temp repo; the resolution commit exists after the marker commit, and no marker remains (`git diff --check` clean).
7. Add the skill to `AGENTS.md` under "Quality & Workflow" (FR-13).
   - **Verify**: `grep -n resolve-merge-conflicts AGENTS.md` shows one entry in that section.
8. Run sandbox scenarios in a throwaway repo under the scratchpad directory and record results in this plan's Verification section: (a) text conflict, (b) no conflict, (c) modify/delete conflict, (d) dirty working tree stop, (e) target branch checked out in another worktree.
   - **Verify**: each scenario's outcome matches the skill text; any mismatch is fixed in `SKILL.md` and re-run.
9. Confirm the setup scripts pick up the new skill.
   - **Verify**: `ls skills/` shows the directory; read `platforms/*/link_skills.sh` and confirm skills are linked by directory enumeration (or add it if listed explicitly).
10. Apply the code review findings to `SKILL.md` (added after review) and re-verify with new scenarios (f) leftover markers after the marker commit, (g) history lookup after the marker commit, (h) marker-less-only conflicts, (i) pre-commit hook rejection.
   - **Verify**: each scenario below matches the skill text.

## Verification
- Static: `SKILL.md` covers FR-1 to FR-19 (excluding dropped FR-3) and NFR-1; checked item by item against `requirements.md`.
- Dynamic: scenarios (a) to (e) of Task 8 and (f) to (i) of Task 10 run in a temp repo; results recorded below.
- Registration: `AGENTS.md` entry present; link scripts pick up the skill.
- Review: `requesting-code-review` was run on the working tree on 2026-11-23; its findings were verified and applied (Task 10). Re-run on the final diff before merging if desired.

### Results (2026-11-23, git 2.56.1, macOS, throwaway repo in the scratchpad)
| Scenario | Result |
|----------|--------|
| (a) text conflict | Pass: `merge --no-ff --no-commit` leaves `UU`; commit is refused while unmerged; after `git add`, the marker commit contains `<<<<<<<`, `|||||||`, `=======`, `>>>>>>>` (zdiff3); the resolution commit follows; the marker grep is clean. |
| (b) no conflict | Pass: merge stages cleanly with `MERGE_HEAD` set and an empty unmerged list; a plain `git commit` completes it. Already-contained source returns "already up to date", handled by the `merge-base --is-ancestor` check. |
| (c) modify/delete | Pass: shows `UD`; `git add` (keep) resolves it; the marker commit succeeds. |
| (d) dirty tree / in-progress | Pass: `git status --porcelain` is non-empty on a dirty tree; the `MERGE_HEAD` / `rebase-*` / `CHERRY_PICK_HEAD` checks via `git rev-parse --git-path` give correct results in the main checkout and in a linked worktree. |
| (e) target held by another worktree | Pass: `git switch main` fails with "already used by worktree"; `git switch -c <new> main` succeeds. |
| Branch name | Pass: `merge/feature-issue36-into-main-<UTC>` passes `git check-ref-format --branch`. |
| (f) leftover markers after marker commit | Pass, and it exposed a defect: `git diff --check` returns 0 even when markers remain (they are already in the index), so verification now relies on `git grep` over all marker files; `git diff --check` is whitespace-only. |
| (g) history lookup after marker commit | Pass after change: `git log --merge` fails once `MERGE_HEAD` is gone (`--merge requires one of the pseudorefs`); replaced with `git log -p <target>...<source> -- <file>`. `git restore --source=HEAD --worktree` brings markers back. |
| (h) marker-less-only conflict | Pass: after `git add`, no unmerged files remain, the merge commit is made in step 5, and a further commit has nothing to commit, so the skill stops there. |
| (i) pre-commit hook rejection | Pass: a hook rejecting `+<<<<<<<` fails the marker commit (rc=1) and `--no-verify` succeeds, matching the "ask before `--no-verify`" rule. `git commit --no-edit` works for a no-conflict `--no-commit` merge without an editor. |
| Not exercised | `rerere` behavior, the `diff3` fallback on git < 2.35, and the two higher-tier review rounds were not run (they depend on the user's environment); they are covered by the skill text only. |

Found while verifying: the precondition snippet used `git rev-parse --verify` on a path; it was replaced with `test -f` and re-verified. `AGENTS.md` entry added; `platforms/*/link_skills.sh` link skills by directory enumeration, so no change is needed (Task 9).

---

## Change History
| Date | Change | Source |
|------|--------|--------|
| 2026-11-23 | Initial draft | requirements.md |
| 2026-11-23 | Tasks 1-9 implemented and verified; results recorded in Verification | Implementation |
| 2026-11-23 | Flow order aligned with SKILL.md (marker-less conflicts before the marker commit); Task 10 and scenarios (f)-(i) added; review findings applied | Code review |
