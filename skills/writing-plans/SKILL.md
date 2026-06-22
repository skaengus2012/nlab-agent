---
name: writing-plans
description: Use when creating a new plan for a feature, refactor, or complex bug fix. Make sure to trigger this skill whenever the user asks to start a coding task, fix a complex bug, refactor code, or write an implementation plan, even if they do not explicitly ask for 'writing-plans'.
---

# Writing Plans

## Overview
A good plan prevents technical debt and reduces rework. Write the plan before writing any code.

## Designing Plans Interactively
If requirements or implementation details are vague before creating a plan (`implementation_plan.md`), negotiate the details with the user step-by-step using the following flow:
1. **Single Query Rule**: Ask only **one** question at a time if clarification is needed (e.g., Ask architectural constraints $\rightarrow$ Ask verification methods).
2. **Sequential Progress Tracking**: Keep track of the current scope details in your inner monologue (e.g., `[Goals: Done], [Requirements: Pending], [Architecture: Pending]`) and query only the first pending item.
3. **Smart Skip**: If the user proactively clarifies both goals and requirements in a single response, mark them as completed and proceed straight to the next pending details (e.g., architecture).
4. **Focused Prompting**: Keep each question concise and focused on the target planning aspect without explaining future sections.
5. **Document after Approval**: Once all necessary information is collected and agreed upon, draft and write the final `implementation_plan.md` for user approval.

## The Structure
A plan must contain:
1. **Context/Goals**: What are we building and why?
2. **Requirements**: Detailed list of what must be achieved.
3. **Architecture/Design**: High-level technical decisions.
4. **Tasks**: A numbered list of atomic, verifiable tasks.
5. **Verification**: How will we prove each task is complete?

## Task Rules
- Each task should be small (15-30 minutes of work).
- Each task must have a clear "pass" condition (e.g., test command).
- Tasks must be independent where possible.

## Example Task
1. Add `UserRepository.findById()` and corresponding unit tests.
   - **Verify**: `pytest tests/test_repository.py`
