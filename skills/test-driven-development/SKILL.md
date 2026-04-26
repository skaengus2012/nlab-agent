---
name: test-driven-development
description: Use when implementing logic-heavy features or fixing bugs - ensures code correctness through Red-Green-Refactor cycles
---

# Test-Driven Development (TDD)

## The Cycle
1. **RED**: Write a failing test for the next small piece of functionality.
2. **GREEN**: Write the minimal amount of code to make the test pass.
3. **REFACTOR**: Clean up the code while keeping the tests passing.

## Rules
- You are not allowed to write any production code unless it is to make a failing unit test pass.
- You are not allowed to write any more of a unit test than is sufficient to fail.
- You are not allowed to write any more production code than is sufficient to pass the one failing unit test.

## Benefits for Android
- Decouples logic from the UI (making it more testable).
- Prevents regressions in complex ViewModel/Repository logic.
- Acts as living documentation for how the code is intended to work.
