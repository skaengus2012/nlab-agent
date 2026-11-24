---
name: resolve-merge-conflicts
description: Use when you need to merge one branch into another and resolve the resulting conflicts with human review. Make sure to use this skill whenever the user asks to merge a branch, resolve merge conflicts, or fix conflicts between branches, even if they do not explicitly ask for 'resolve-merge-conflicts'.
---

# Resolve Merge Conflicts

## Overview
Merge a source branch into a target branch on a **new branch**, commit the conflicted state first (the *marker commit*), then resolve the conflicts with the user's confirmation and commit the resolution **separately** (the *resolution commit*). The two commits let a human review exactly what the resolution changed (`git diff <marker-commit> <resolution-commit>`).

## When to Use
- The user wants to merge one branch into another and expects conflicts, or a merge just conflicted.
- The user wants conflict resolutions proposed and reviewed before they are committed.

## Scope
- Supports `merge` only. `rebase`, `cherry-pick`, `stash pop`, and `revert` are out of scope; tell the user so and stop if they ask for those.
- Never push. Never merge into the target branch itself. Integration (e.g., squash) is the user's call.

## Rules
- Ask **one question at a time** and wait for the answer.
- Never create the resolution commit before the user has explicitly approved the resolution diff.
- Never run `git stash` automatically (the stash stack is shared across worktrees).
- Never use `--no-verify` unless the user explicitly agrees.
- In this flow `ours` is the **target** side and `theirs` is the **source** side. When asking the user, say "target" and "source", not `ours`/`theirs`.
- Git messages may be localized; detect state with exit codes and `git diff --name-only --diff-filter=U`, not by parsing messages.

## Flow

### 1. Check preconditions and remember where you started
```bash
git status --porcelain                                     # must be empty
test -f "$(git rev-parse --git-path MERGE_HEAD)"           # merge in progress
test -d "$(git rev-parse --git-path rebase-merge)" -o -d "$(git rev-parse --git-path rebase-apply)"   # rebase in progress
test -f "$(git rev-parse --git-path CHERRY_PICK_HEAD)"     # cherry-pick in progress
git branch --show-current                                  # empty means detached HEAD; then record `git rev-parse HEAD`
```
Each `test` succeeding (exit 0) means that operation is in progress. Stop and tell the user if the working tree is dirty or any operation is in progress. Let the user decide how to clean up; do not stash for them. Record the **original branch** (or SHA) so you can return to it.

### 2. Ask for the branches (step by step)
1. Ask which branch to merge (**source**).
2. Ask which branch it should be merged into (**target**).
3. Ask whether to use local branches or their `origin/` counterparts, and whether to run `git fetch` first.

Check that both refs exist (`git rev-parse --verify <ref>`). Then check containment:
```bash
git merge-base --is-ancestor <source> <target>   # exit 0: source already in target; 1: not contained; 128: bad ref, stop
```
Exit 0 means "nothing to merge": report it and stop. If the target is an ancestor of the source, a fast-forward would be possible, but this flow still uses `--no-ff` to keep a reviewable merge commit; mention it.

### 3. Create the work branch
Name pattern: `merge/<source-slug>-into-<target-slug>-<yyyyMMdd>T<HHmmss>Z`

- Slug: strip a leading `origin/`, replace `/` with `-`, and truncate each slug to 40 characters.
- Time: **UTC, 24-hour**: `date -u +%Y%m%dT%H%M%SZ` (works on macOS and GNU).
- Validate: `git check-ref-format --branch "<name>"`.
- If the name exists (`git show-ref --verify --quiet refs/heads/<name>`), append `-2`, `-3`, ... If a local branch literally named `merge` exists, the `merge/` prefix is impossible; ask the user for another prefix.
- If other `merge/<source-slug>-into-<target-slug>-*` branches exist, ask the user to choose:
  - **reuse**: `git switch <existing>`, then look for committed conflict markers **before** the ancestor check. After step 6 the source is already an ancestor of the branch, so `--is-ancestor` alone cannot tell a finished branch from one that stopped at the marker commit:
    ```bash
    git grep -lE '^(<<<<<<<|\|\|\|\|\|\|\||>>>>>>>)( |$)' HEAD | sed 's/^HEAD://'     # non-empty output: markers are committed in these files
    ```
    - **Markers found**: the branch holds an unresolved marker commit (the earlier run stopped before step 9). Tell the user it is a broken-build state, take the printed files as the **marker files** list and the latest merge commit (`git log --merges -1`) as the marker commit, and continue at step 7. Check hits by hand for files that legitimately contain marker text, as in step 8.
    - **No markers**: if `git merge-base --is-ancestor <source> HEAD` succeeds the merge is already done, report it and stop; otherwise continue at step 4 on that branch.
  - **delete and recreate**: only after the user confirms by name; `git branch -D <existing>` fails if it is checked out here or in another worktree, in which case fall back to creating a new one.
  - **create new**.

Create the branch **from the target ref without checking the target out**. The target may already be checked out in another worktree, which makes `git switch <target>` fail. Pass `--no-track`: with a remote-tracking target such as `origin/main`, git otherwise sets it as the upstream, so a bare `git pull` merges new target commits into the work branch and, with `push.default=upstream`, a bare `git push` sends the work branch (including the broken-build marker commit) to the target branch on the remote:
```bash
git switch -c "<name>" --no-track <target-ref>
```

### 4. Run the merge
Disable `rerere` so every conflict is visible. Use the `zdiff3` conflict style so the common ancestor appears in the markers; it needs git 2.35 or newer (`git --version`), otherwise use `diff3`:
```bash
STYLE=zdiff3     # or diff3 on git < 2.35
git -c rerere.enabled=false -c merge.conflictStyle=$STYLE merge --no-ff --no-commit <source-ref>
test -f "$(git rev-parse --git-path MERGE_HEAD)"     # exit 0: the merge started
git diff --name-only --diff-filter=U                 # list of conflicted files
```
Check that the merge actually started **before** reading the list. An empty list does not mean "no conflicts" on its own: a merge that fails to start (for example `refusing to merge unrelated histories`, or an ignored file that would be overwritten) also leaves the list empty.
- **The merge did not start** (`MERGE_HEAD` does not exist): show git's message, stop, `git switch <original branch>` (or the recorded SHA), and offer to delete the work branch. `git merge --abort` fails here (there is no merge to abort), so do not run it.
- **The merge started with no conflicts** (`MERGE_HEAD` exists and the list is empty): `git commit --no-edit` the merge as is, report that no resolution was needed, and stop. Skip the rest.
- **Conflicts**: continue.

**Cancelling:** until step 6 is done the user can stop at any time. If `MERGE_HEAD` exists, run `git merge --abort`. Then `git switch <original branch>` (or the recorded SHA), and offer to delete the work branch. After step 6, just switch back and keep the branch.

### 5. Handle conflicts that have no markers
Conflicts such as binary files, modify/delete, rename/rename, submodules, file mode, and LFS pointers cannot be expressed as markers and cannot be left unmerged in a commit. `git status --short` shows them as `UD`, `DU`, `AU`, `UA`, `DD`, or `AA` on binary files. For each one:
1. Explain the situation and the options.
2. Ask the user which side to keep (one question per file), naming sides as **target** or **source**.
3. Apply the choice: `git add <file>` (keep what is in the tree), `git rm <file>` (delete), or `git checkout --ours|--theirs <file>` followed by `git add <file>` (`--ours` = target, `--theirs` = source). A conflicted submodule may need `git add <submodule>` after choosing the commit inside it; ask the user rather than guess.
4. Remember each decision; it goes into the commit message in step 6.

After this step re-run `git diff --name-only --diff-filter=U`. That list is the **marker files** list; keep it, it is used in steps 6 to 9.
- If it is **empty**, every conflict was marker-less and already resolved. Commit with `git commit -m "Merge <source> into <target>" -m "<one line per decision>"`, report it, and **stop** (no marker commit, no steps 6 to 9, and no broken-build warning applies).

### 6. Commit the conflicted state (marker commit)
Stage the marker files so git allows the commit, then commit. The result is a merge commit whose tree contains conflict markers.
```bash
git add <marker files>
git commit -m "Merge <source> into <target> (conflicted state, unresolved)" \
           -m "<one line per marker-less decision, e.g. g.txt: kept the target version>"
git rev-parse HEAD     # record this as the marker commit
```
- Tell the user this is intentionally a **broken-build commit** kept only for review. It should not be integrated as is; squashing the work branch is a good integration choice.
- If a pre-commit hook rejects the markers, show the hook's message and ask whether to retry with `--no-verify`. Do not retry without consent. The same rule applies to the resolution commit in step 9.

### 7. Analyze and propose resolutions
For each marker file, read the three sides (`<<<<<<<` target, `|||||||` base, `=======`/`>>>>>>>` source) and the surrounding code. The merge state is gone after step 6, so look at each side's history with:
```bash
git log -p <target-ref>...<source-ref> -- <file>
```

For every conflict hunk produce:
- the proposed resolution (the exact resulting lines),
- a short reason, and
- a confidence level: **high** (mechanical: one side unchanged from base, import or ordering, identical intent) or **low** (both sides changed the same logic, behavior depends on intent, or you are unsure).

**Low-confidence hunks get two review rounds before the user is asked:**
1. Tell the user that the conflicting code of that hunk will be sent to another model or subagent, then delegate it (sides, base, your proposal, surrounding code) to the strongest available model (see `model_resolution` in `AGENTS.md`) and ask it to either confirm the proposal or reject it with reasons. If it proposes an alternative, that counts as a rejection.
2. Repeat with an independent second review. Do not show the first reviewer's verdict to the second.
3. If both reviewers confirm your proposal, treat the hunk as resolved but still show the reasoning in the proposal. If either rejects it, or states real doubt, the hunk is **ambiguous**: do not run further rounds; ask the user (step 8), presenting the options and each reviewer's reasoning.

If no stronger model is available, or the user does not want the code delegated, say so and ask the user about every low-confidence hunk.

### 8. Confirm with the user
Confirm **per file**, not once for everything and not hunk by hunk, except for ambiguous hunks:
1. For each marker file, present the proposal: per hunk, the resolution, reason, and confidence. Ask one question per file ("apply this resolution to `<file>`?").
2. For each ambiguous hunk, ask separately and let the user choose or write the resolution.
3. If the user rejects a file's proposal, revise it with their input and ask again.

Apply the confirmed resolutions to the working tree only (no commit yet), then verify. `git diff --check` does **not** detect markers that were already committed in step 6, so use `git grep` for markers and `git diff --check` only for whitespace errors:
```bash
git grep -nE '^(<<<<<<<|\|\|\|\|\|\|\||>>>>>>>)( |$)' -- <marker files>   # must print nothing
git diff --check                                     # whitespace errors only
git diff HEAD                                        # diff against the marker commit
```
`git grep` can false-positive on files that legitimately contain marker text (docs, test fixtures); check such hits by hand rather than deleting them blindly.

Every file in the marker files list must be resolved and confirmed. If any file is still pending or was rejected, do not proceed to step 9. Show the `git diff HEAD` result to the user and ask for **final approval** of the whole resolution. Without approval, do not commit; revise, or restore the files with `git restore --source=HEAD --worktree -- <files>`.

### 9. Commit the resolution
Only after final approval:
```bash
git add <marker files>
git commit -m "Resolve merge conflicts between <source> and <target>"
```
Report the work branch name, the marker commit hash from step 6, the resolution commit hash, and how to review: `git diff <marker-commit> HEAD`. Remind the user that nothing was pushed, that they started on `<original branch>`, and that the work branch can be integrated (e.g., squashed) as they choose.

## Red Flags
- **Resolving without asking**: committing the resolution before the final approval.
- **Skipping the marker commit**: the separate conflicted-state commit is the whole point of reviewability (except when no markers exist at all; see step 5).
- **Trusting `git diff --check` for markers**: it only checks whitespace once markers are committed; use `git grep`.
- **Checking out the target branch**: fails when another worktree holds it; branch from the ref instead.
- **Auto-stashing a dirty tree**: stop and ask instead.
- **Trusting `rerere`**: silently auto-resolved conflicts never reach the review; keep it disabled for this run.
- **Guessing on ambiguous hunks**: two review rounds, then ask the user.
