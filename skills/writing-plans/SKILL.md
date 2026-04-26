---
name: writing-plans
description: Use when creating a new plan for a feature, refactor, or complex bug fix - ensures structured thinking and clear requirements before coding starts
---

# Writing Plans

## Overview
A good plan prevents technical debt and reduces rework. Write the plan before writing any code.

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
