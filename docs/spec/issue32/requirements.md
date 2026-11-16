# Requirements Analysis: [Task] Review whether the skillify and writing-skills skills should exist (#32)

- Issue: https://github.com/skaengus2012/nlab-agent/issues/32
- Parent issue: None
- Labels: skills
- Created: 2026-11-16
- Last Updated: 2026-11-17
- Analysis Baseline: 2026-11-16T16:31:23Z

## Background and Problem
nlab-agent has the `skillify` and `writing-skills` skills. It is unclear whether they are actually used, and their purpose may overlap with `skill-creator`, which is already built into Claude.

## Goals
Decide, for each of `skillify` and `writing-skills`, whether it should be kept, merged, or removed, based on a functional comparison with `skill-creator`, and clean up related artifacts if the decision is to remove or merge.

## Scope
### In Scope
- Functional comparison of `skillify`, `writing-skills`, and `skill-creator`.
- A keep / merge / remove conclusion for each skill.
- If removing or merging: cleanup of related docs and setup scripts.

### Out of Scope
- N/A (the issue states no exclusions).

## Functional Requirements
| ID | Requirement | Source |
|----|-------------|--------|
| FR-1 | Produce a functional comparison of `skillify`, `writing-skills`, and `skill-creator`. | Body |
| FR-2 | Give a conclusion (keep, merge, or remove) for each skill. | Body |
| FR-3 | If a skill is removed or merged, clean up the related docs and setup scripts. | Body |

## Non-Functional Requirements
| ID | Requirement | Source |
|----|-------------|--------|
| N/A | The issue states no non-functional requirements. | - |

## Acceptance Criteria
- [ ] A comparison of the three skills' functionality exists.
- [ ] Each of `skillify` and `writing-skills` has a keep / merge / remove conclusion.
- [ ] For any removed or merged skill, related docs and setup scripts are cleaned up.

## Impact
Confirmed by searching the repository for the skill names:
- `skills/skillify/SKILL.md`, `skills/writing-skills/SKILL.md`: the skills themselves.
- `README.md:76` and `AGENTS.md:45`: list `writing-skills`, `skillify` under "Knowledge & Meta".
- `docs/spec/issue27/*`: historical spec documents that mention these skills (evals, plan, requirements, emphasis inventory).
- `platforms/*/setup.sh` and `link_skills.sh`: no direct references to either skill name were found (they appear to link the `skills/` directory generically).
- `skill-creator` does not exist in this repository (the issue describes it as built into Claude); it only appears in docs/spec/issue27.

## Open Questions
- N/A

## Conflicts and Notes
No conflicts: the issue has no comments and no parent issue.

Decisions confirmed by the user in chat (not stated in the issue):
- Neither `skillify` nor `writing-skills` will be used, so both are to be removed. If needed later, they can be restored from git history.
- Historical references under `docs/spec/issue27/` are past records and are left as-is.

---

## Change History
| Date | Change | Source |
|------|--------|--------|
| 2026-11-17 | Initial draft | Body |
| 2026-11-17 | Resolved open question: lack of a built-in `skill-creator` on Antigravity and Codex is not a concern, because other equivalent skills already exist there. | User (chat) |
| 2026-11-17 | Resolved open questions: the user will not use either skill (remove both; roll back via git if needed), and `docs/spec/issue27/` history is left untouched. | User (chat) |
| 2026-11-17 | Resolved open question: project `CLAUDE.md` is a symlink to `AGENTS.md`, so a single `AGENTS.md` edit covers both. | Codebase check |
