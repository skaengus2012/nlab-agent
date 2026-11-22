# Requirements Analysis: [Feature] Add skill for resolving merge conflicts between branches (#36)

- Issue: https://github.com/skaengus2012/nlab-agent/issues/36
- Parent issue: None
- Labels: skills
- Created: 2026-11-22
- Last Updated: 2026-11-23
- Analysis Baseline: 2026-11-22T12:00:38Z

## Background and Problem
When a conflict occurs during a merge or rebase, it has to be resolved manually every time, which is tedious and repetitive.

## Goals
Provide a new skill that helps resolve conflicts between branches, so the user no longer resolves each conflict entirely by hand while keeping control over what gets applied and being able to review the result as a separate commit.

## Scope
### In Scope
- A new skill for resolving conflicts between branches.
- The `merge` workflow only.
- Receiving the source and target branches from the user step by step.
- Always working on a newly created branch.
- Analysis of conflicting files and a proposed resolution for each conflict.
- Committing the unresolved (conflict-marker) merge state first, then committing the resolution separately.

### Out of Scope
- `rebase` (dropped; too complex, see FR-3).
- Other conflict-producing operations such as `cherry-pick`, `stash pop`, `revert` (user: not needed).

## Functional Requirements
| ID | Requirement | Source |
|----|-------------|--------|
| FR-1 | Add a new skill that helps resolve conflicts between branches. | Body |
| FR-2 | The skill supports conflicts that occur during a `merge`. | Body |
| ~~FR-3~~ | ~~The skill supports conflicts that occur during a `rebase`.~~ (Dropped: user decided to support `merge` only because the commit-and-review flow of FR-9/FR-10 makes `rebase` too complex) | Body; dropped by user decision (2026-11-23) |
| FR-4 | The skill analyzes the conflicting files. | Body |
| FR-5 | The skill proposes a resolution for each conflict. | Body |
| FR-6 | The skill applies a resolution only after the user has reviewed and confirmed the proposal. | Body |
| FR-7 | The skill asks the user, step by step, which branch to merge into which branch. | User decision (2026-11-23) |
| FR-8 | The skill always creates a new branch for the merge work. | User decision (2026-11-23) |
| FR-9 | The skill first commits the merge result in its conflicted state (conflict markers left unresolved) so a human can review it. | User decision (2026-11-23) |
| FR-10 | The skill then commits the resolution as a separate follow-up commit. | User decision (2026-11-23) |
| FR-11 | When the skill is not confident about a conflict, it first has the resolution reviewed by a higher-tier model in two review rounds; only if the conflict is still ambiguous after both rounds does it ask the user instead of deciding. | User decision (2026-11-23); refined by user (2026-11-23) |
| FR-12 | Confirmation granularity: per file by default, with hunks that remain ambiguous after the FR-11 reviews asked individually, and a final approval of the diff against the marker commit before the resolution commit is created. | User delegated the choice; Opus review (2026-11-23) |
| FR-13 | The skill is named `resolve-merge-conflicts`, lives in shared `skills/`, and is listed in the `AGENTS.md` skills map under "Quality & Workflow". | User delegated the choice; Opus review (2026-11-23) |
| FR-14 | New branch name pattern: `merge/<source-slug>-into-<target-slug>-<yyyyMMdd>T<HHmmss>Z`. Use 24-hour UTC time (`date -u +%Y%m%dT%H%M%SZ`); replace `/` in branch names with `-`; validate with `git check-ref-format --branch` and truncate long names; on name collision add a `-2` suffix; handle a pre-existing local branch named `merge`; if a `merge/*` branch for the same pair already exists, let the user choose reuse, delete and recreate, or create new. | User approval of Opus recommendation (2026-11-23) |
| FR-15 | Preconditions: require a clean working tree and no in-progress merge/rebase/cherry-pick (checked worktree-safely via `git rev-parse --git-path`); stop and inform the user otherwise. Never auto-`git stash`, because the stash stack is shared across worktrees. | User approval of Opus review (2026-11-23) |
| FR-16 | Worktree/ref handling: create the new branch from the target ref (`git switch -c <new> <target>`) instead of checking out the target, since it may be checked out in another worktree. Ask whether to base on local or `origin/` refs and whether to fetch first. | User approval of Opus review (2026-11-23) |
| FR-17 | Marker commit handling: stage the markers so the commit is allowed while paths are unmerged; if a pre-commit hook blocks markers, use `--no-verify` only with explicit user consent; mention to the user that the marker commit is a broken-build commit and that the final integration method (e.g., squash) matters. | User approval of Opus review (2026-11-23) |
| FR-18 | Conflicts without markers (binary, modify/delete, rename/rename, submodule, file mode, LFS) are asked to the user, and the decision is recorded in the commit message. | User approval of Opus review (2026-11-23) |
| FR-19 | Detection and verification: account for `rerere` silently auto-resolving conflicts; skip the marker commit when there are no conflicts; after resolution, check leftover markers with `git diff --check` and grep (including `|||||||` under `diff3`/`zdiff3`), tolerating false positives in files that legitimately contain marker text. | User approval of Opus review (2026-11-23) |

## Non-Functional Requirements
| ID | Requirement | Source |
|----|-------------|--------|
| NFR-1 | The resolution commit is never created, and no resolution is committed, before the user's explicit confirmation (safety constraint behind FR-6). | Body; refined with Opus review |

## Acceptance Criteria
- [ ] A new skill `resolve-merge-conflicts` exists under `skills/` and is listed in `AGENTS.md` (FR-1, FR-13).
- [ ] The skill asks for the source and target branches step by step (FR-7).
- [ ] The skill creates a new branch for the work, named per the FR-14 pattern, from the target ref (FR-8, FR-14, FR-16).
- [ ] The skill stops on a dirty working tree or an in-progress merge/rebase/cherry-pick, without auto-stashing (FR-15).
- [ ] The conflicted merge state is committed as is, before any resolution (FR-9).
- [ ] For each conflicting file, the skill presents an analysis and a proposed resolution per conflict (FR-4, FR-5).
- [ ] Low-confidence conflicts get two review rounds by a higher-tier model, and only those still ambiguous afterwards are asked to the user individually (FR-11, FR-12).
- [ ] The user approves the resolution diff before the resolution commit is made, and the resolution is a separate commit (FR-6, FR-10, FR-12, NFR-1).
- [ ] Marker-less conflicts are asked to the user and recorded in the commit message; no leftover markers remain after resolution (FR-18, FR-19).
- [ ] Hook-blocked marker commits are handled per FR-17.

## Impact
- `skills/` is the source of truth for skills (per `AGENTS.md`); the new skill is added as a new directory there. Existing siblings: `brainstorming`, `create-gh-issue`, `create-gh-issue-analysis-report`, `create-plans`, `receiving-code-review`, `requesting-code-review`, `systematic-debugging`, `test-driven-development`, `verification-before-completion`.
- `AGENTS.md` skills map ("Quality & Workflow" section) gets a new entry.
- The skill should not depend on Claude-only tools so that it can stay in shared `skills/` (Opus review). The higher-tier model review in FR-11 must therefore be described in an agent-neutral way (the `AGENTS.md` `model_resolution` section assigns Opus-tier models to strategic work).

## Open Questions
N/A (all previous questions are resolved; see Change History).

## Conflicts and Notes
- No comments exist and there is no parent issue. Requirements FR-7 to FR-19 come from the user's decisions in conversation (2026-11-23), not from the issue body.
- The issue body names both `merge` and `rebase`. The user later narrowed it to `merge` only; the later decision wins, so FR-3 is dropped and `rebase` is out of scope.
- NFR-1 was refined: Opus pointed out that "no files written before confirmation" conflicts with the marker-commit-then-resolve flow, so the constraint is now "no resolution commit before confirmation". The resolution may be applied to the working tree first and shown as a diff against the marker commit.

---

## Change History
| Date | Change | Source |
|------|--------|--------|
| 2026-11-23 | Initial draft | Body |
| 2026-11-23 | Dropped `rebase` (FR-3); added FR-7 to FR-13 (step-by-step branch input, new branch, marker commit then resolution commit, ask on low confidence, confirmation granularity, skill name/location/category); refined NFR-1; moved branch naming and edge cases to Open Questions; removed resolved questions | User answers in conversation, Opus review |
| 2026-11-23 | Resolved all Open Questions: approved branch naming (FR-14); adopted Opus edge cases as FR-15 to FR-19; confirmed interpretations (no `cherry-pick`/`stash pop`/`revert`; `AGENTS.md` skills map) | User answers in conversation |
| 2026-11-23 | FR-11 refined: ambiguous conflicts get two review rounds by a higher-tier model before asking the user; FR-12 and acceptance criteria aligned | User request in conversation |
