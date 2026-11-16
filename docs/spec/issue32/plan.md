# Plan: [Task] Review whether the skillify and writing-skills skills should exist (#32)

- Issue: https://github.com/skaengus2012/nlab-agent/issues/32
- Requirements: docs/spec/issue32/requirements.md
- Created: 2026-11-17
- Last Updated: 2026-11-17

## Context/Goals
`skillify` and `writing-skills` may overlap with `skill-creator`, which is built into Claude. The user decided neither skill will be used, so both are removed. Recovery, if ever needed, is done through git history. The goal is to remove both skills and clean up every live reference, leaving the three platforms' setup in a consistent state.

## Requirements
Requirement IDs follow `requirements.md`.
- FR-1: Compare the three skills (see the comparison below).
- FR-2: Conclusion for each skill.
- FR-3: Clean up related docs and setup scripts.
- Decisions (2026-11-17, user answers in chat):
  - D-1: Remove both `skillify` and `writing-skills`.
  - D-2: Leave `docs/spec/issue27/` as-is (historical records).
  - D-3: The missing built-in `skill-creator` on Antigravity and Codex is not a concern, because equivalent skills already exist there.

## Architecture/Design
### Comparison (FR-1) and conclusion (FR-2)
| Skill | What it does | Overlap with `skill-creator` | Conclusion |
|-------|--------------|------------------------------|------------|
| `skillify` | Turns a workflow from the current session into a `SKILL.md` draft (extract inputs, steps, success criteria; register in `AGENTS.md`). | Same goal: create a new skill from a workflow. | Remove |
| `writing-skills` | A TDD-style guide for writing or updating skills (RED baseline, minimal skill, verify, close loopholes), progressive disclosure, and `SKILL.md` structure. | Same goal: create, modify, and verify skills; `skill-creator` also runs evals and benchmarks. | Remove |
| `skill-creator` | Built into Claude; creates and improves skills, runs evals, optimizes descriptions. | - | Keep (not owned by this repository) |

Both repository skills are no longer used, and their purpose is covered by `skill-creator`. The "Single Query Rule" dialog principles in `writing-skills` are already written inline in `create-plans` and `skillify`'s own flow, and no remaining skill references `writing-skills`.

### Cleanup scope (FR-3)
- Delete `skills/skillify/` and `skills/writing-skills/`.
- `AGENTS.md` (`CLAUDE.md` is a symlink to it, so one edit covers both): the "Knowledge & Meta" category lists only these two skills, so remove the whole category.
- `README.md`: remove the "Knowledge & Meta" row from the skills table.
- Setup scripts need **no code change**. The three `link_skills.sh` scripts iterate `skills/*` and already remove broken symlinks, so re-running setup deletes the stale `~/.claude/skills/{skillify,writing-skills}` links and the matching Codex and Antigravity links.
- `docs/spec/issue27/` is untouched (D-2).

## Tasks
1. Delete the two skill directories with `git rm -r skills/skillify skills/writing-skills`.
   - **Verify**: `ls skills/` lists neither name; `git status --short` shows only deletions of those two `SKILL.md` files.
2. Remove the "Knowledge & Meta" category (heading and list line) from `AGENTS.md`.
   - **Verify**: `grep -nE "Knowledge & Meta|writing-skills|skillify" AGENTS.md CLAUDE.md` has no output, and the `<skills>` block remains well-formed (the `</skills>` tag follows the "Quality & Workflow" list).
3. Remove the "Knowledge & Meta" row from the `README.md` skills table.
   - **Verify**: `grep -nE "Knowledge & Meta|writing-skills|skillify" README.md` has no output; the table still renders (three rows under the header).
4. Check for leftover live references.
   - **Verify**: `grep -rnE "skillify|writing-skills" --exclude-dir=.git --exclude-dir=issue27 --exclude-dir=issue32 .` has no output.
5. Re-run the setup link step to remove stale symlinks, then confirm.
   - **Verify**: run `bash platforms/claude/link_skills.sh`; `ls -la ~/.claude/skills | grep -E "skillify|writing-skills"` has no output. Repeat with `platforms/codex/link_skills.sh` and `platforms/antigravity/link_skills.sh` (the user confirms these two ahead of time, since they change files outside the repository), then `ls ~/.codex/skills ~/.gemini/antigravity/skills` shows neither name.
6. Run the existing test.
   - **Verify**: `bash tests/permissions-apply.test.sh` exits with code 0.

## Verification
- Automated: the `grep`/`ls` checks in Tasks 1 to 5 and `bash tests/permissions-apply.test.sh` in Task 6.
- Acceptance criteria mapping: comparison exists (Design table) = FR-1; per-skill conclusion (Design table) = FR-2; docs and setup cleanup = Tasks 1 to 5 (FR-3).
- Before claiming completion, follow `verification-before-completion` and check the actual output of the commands above.

---

## Change History
| Date | Change | Source |
|------|--------|--------|
| 2026-11-17 | Initial draft. Recorded decisions D-1 to D-3 and the comparison table. | requirements.md, user answers in chat |
