---
name: systematic-debugging
description: Use when investigating a bug - prevents "guess-and-check" by forcing a logical hypothesis-driven approach
---

# Systematic Debugging

## Core Principle
**Do not change code until you have a hypothesis and a way to verify it.**

## The Process
1. **Reproduce**: Create a reliable, minimal reproduction case (e.g., a failing test).
2. **Observe**: Gather data (logs, traces, state) without making assumptions.
3. **Hypothesize**: State exactly what you think is wrong and WHY.
4. **Experiment**: Change ONE thing to test the hypothesis.
5. **Verify**: Did the change have the expected effect?
6. **Fix**: Implement the permanent solution once the cause is confirmed.

## Red Flags
- Changing multiple things at once.
- "I'll just try this and see if it works."
- Ignoring error messages.
- Not running the reproduction case after a "fix".
