---
name: verification-before-completion
description: Use before claiming a task is done or a bug is fixed - ensures that the claim is backed by evidence
---

# Verification Before Completion

## The Gate Function
Before claiming any status or saying "I'm done":
1. **Identify**: What command or action proves this work is correct?
2. **Run**: Execute the full verification (e.g., run tests, check UI).
3. **Read**: Look at the actual output, exit codes, and logs.
4. **Verify**: Does the evidence match the claim?

## Red Flags
- Using words like "should", "probably", or "seems to".
- Claiming success because a previous run worked.
- Trusting your own assumptions without running the verification command.
- **Environment Friction**: Skipping because "the test is hard to run in this workspace". (Must solve the setup issue instead)

## Checklist
- [ ] Tests pass (with output evidence).
- [ ] Linter is clean.
- [ ] The original problem/symptom is gone.
- [ ] No new regressions introduced.
