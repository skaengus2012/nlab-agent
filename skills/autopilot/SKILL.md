---
name: autopilot
description: Use for complex, multi-step tasks that require expansion, planning, and execution - allows the agent to work autonomously toward a goal
---

# Autopilot

## Overview
Autopilot is a multi-phase workflow for autonomous task completion.

## Phases
1. **Phase 0 - Expansion**: Turn a vague goal into a detailed technical specification.
2. **Phase 1 - Planning**: Create a step-by-step implementation plan from the spec.
3. **Phase 2 - Execution**: Implement the plan by executing tasks.
4. **Phase 3 - QA**: Run tests and fix any failures until the build is stable.
5. **Phase 4 - Validation**: Final review of the work against the original requirements.

## When to Use
- Building a new feature from scratch.
- Major refactoring of a module.
- Complex migrations (e.g., migrating a library).

## Guidelines
- Ensure each phase is completed and verified before moving to the next.
- If stuck in a QA loop (same error 3 times), stop and ask for human guidance.
