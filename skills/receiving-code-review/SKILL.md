---
name: receiving-code-review
description: Use when receiving code review feedback. Ensures technical rigor and verification instead of blind implementation.
---

# Code Review Reception

## Core Principle
**Verify before implementing. Ask before assuming. Technical correctness over social comfort.**

## The Response Pattern
1. **READ**: Complete feedback without reacting.
2. **UNDERSTAND**: Restate requirement in own words or ask for clarification.
3. **VERIFY**: Check against codebase reality.
4. **EVALUATE**: Is this technically sound for THIS specific codebase?
5. **RESPOND**: Technical acknowledgment or reasoned pushback.
6. **IMPLEMENT**: One item at a time, test each.

## Handling Feedback
- **NEVER** use performative agreement like "You're absolutely right!" or "Great point!".
- **INSTEAD**: Just state the technical fix or push back with reasoning.
- **Push back when**:
  - Suggestion breaks existing functionality.
  - Reviewer lacks full context.
  - Violates YAGNI (unused feature).
  - Technically incorrect for this stack.

## Implementation Order
1. Clarify anything unclear FIRST.
2. Fix blocking issues (breaks, security).
3. Simple fixes (typos, imports).
4. Complex fixes (refactoring, logic).
5. Test each fix individually.
