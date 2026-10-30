---
name: create-plans
description: Use when creating a new plan for a feature, refactor, or complex bug fix. Make sure to trigger this skill whenever the user asks to start a coding task, fix a complex bug, refactor code, or write an implementation plan, even if they do not explicitly ask for 'create-plans'.
---

# Create Plans

## Overview
A good plan prevents technical debt and reduces rework. Write the plan before writing any code.

**Input**: a GitHub issue number (e.g. `869`) or URL. If the user did not provide one and it cannot be determined from the conversation or `docs/spec/`, ask for it. Do not guess or invent a number; if the work has no issue, ask the user whether to create one (`create-gh-issue`) or which number to use.

**Output**: `docs/spec/issue<number>/plan.md` (one file per issue; create the directory if it does not exist). The requirements report of the same issue (`requirements.md`) lives in the same folder; read it first when it exists.

**Language**: Write the plan in the language of the existing plan when updating one, otherwise in the language of `requirements.md` or the issue. Do not ask the user about the language. Code blocks, file paths, and commands stay in English.

## Designing Plans Interactively
If requirements or implementation details are vague before creating a plan (`plan.md`), negotiate the details with the user step-by-step using the following flow:
1. **Single Query Rule**: Ask only **one** question at a time if clarification is needed (e.g., Ask architectural constraints $\rightarrow$ Ask verification methods).
2. **Sequential Progress Tracking**: Keep track of the current scope details in your inner monologue (e.g., `[Goals: Done], [Requirements: Pending], [Architecture: Pending]`) and query only the first pending item.
3. **Smart Skip**: If the user proactively clarifies both goals and requirements in a single response, mark them as completed and proceed straight to the next pending details (e.g., architecture).
4. **Focused Prompting**: Keep each question concise and focused on the target planning aspect without explaining future sections.
5. **Document after Approval**: Once all necessary information is collected and agreed upon, draft and write the final `plan.md` for user approval.

## The Structure
A plan must contain:
1. **Context/Goals**: What are we building and why?
2. **Requirements**: Detailed list of what must be achieved.
3. **Architecture/Design**: High-level technical decisions.
4. **Tasks**: A numbered list of atomic, verifiable tasks.
5. **Verification**: How will we prove each task is complete?
6. **Change History**: Date, what changed, and the source of each change to the plan.

## If the plan already exists
The plan always represents the **current state** of the plan. Never append a new section after a `---` separator and never regenerate it from scratch; edit in place.

1. Read the existing plan and its `Change History`.
2. Modify the affected items directly (requirements, design, tasks, verification).
3. Do not delete a dropped task or reuse its number. Mark it as `~~Task 3~~ (Dropped: <reason>)`. New tasks take the next unused number.
4. Update `Last Updated`.
5. Add one row to `Change History` (date, what changed, source). Never rewrite past rows.
6. If nothing needs to change, do not touch the file and report that.

## Template
```markdown
# Plan: <issue title> (#<number>)

- Issue: <URL>
- Requirements: docs/spec/issue<number>/requirements.md (or "None")
- Created: <YYYY-MM-DD>
- Last Updated: <YYYY-MM-DD>

## Context/Goals
...

## Requirements
...

## Architecture/Design
...

## Tasks
1. ...
   - **Verify**: ...

## Verification
...

---

## Change History
| Date | Change | Source |
|------|--------|--------|
| <YYYY-MM-DD> | Initial draft | <requirements.md / user request / review comment> |
```

## Task Rules
- Each task should be small (15-30 minutes of work).
- Each task must have a clear "pass" condition (e.g., test command).
- Tasks must be independent where possible.

## Example Task
1. Add `UserRepository.findById()` and corresponding unit tests.
   - **Verify**: `pytest tests/test_repository.py`

## Red Flags
- **Guessing the issue number**: Ask the user instead of inventing a path.
- **Appending or overwriting an existing plan**: Do not append new sections or regenerate from scratch. Edit in place, keep task numbers, and log the change in `Change History`.
