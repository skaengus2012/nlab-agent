---
name: receiving-code-review
description: Use when receiving code review feedback. Ensures technical rigor and verification instead of blind implementation.
---

# Code Review Reception

## Core Principle
**Verify before implementing. Ask before assuming. Technical correctness over social comfort.**

## The Rigorous Response Workflow
1. **READ**: Read all comments in the thread first. Do not start implementing immediately.
2. **ANALYZE & VERIFY**:
   - Use `grep` or `find` to check the current state of the code mentioned.
   - Identify if the suggestion conflicts with existing patterns or requirements.
   - **Mandatory**: If the feedback is about a bug, reproduce it first.
3. **EVALUATE**:
   - **Agree**: If the suggestion is technically superior and fits the context.
   - **Clarify**: If the intent is unclear.
   - **Push Back**: If the suggestion is technically incorrect, introduces debt, or violates project rules (e.g., YAGNI).
4. **IMPLEMENT & VERIFY**:
   - **Commit** the fix for each comment separately.
   - **Mandatory**: Run the `verification-before-completion` skill for every change.
5. **RESPOND**: Reply to the thread using the templates below.

## Response Templates
Use these patterns to maintain professional rigor:

### Critical/Blocking Feedback
> "@[reviewer], I've analyzed the issue. The suggested change prevents [problem]. I've implemented the fix in [commit-hash] and verified it with [test-command]."

### Technical Push-back
> "@[reviewer], I've evaluated this suggestion against the current architecture. Implementing this would [negative-impact, e.g., break X or introduce Y]. I recommend [alternative] instead because [reason]."

### Minor/Style Feedback
> "@[reviewer], Fixed as suggested in [commit-hash]. Verification passed."

## Evaluation Checklist
Before clicking "Reply", ask yourself:
- [ ] Did I verify this change with `verification-before-completion`?
- [ ] Did I provide a technical rationale, or just performative agreement?
- [ ] Is there a link to the specific commit or diff?

## Examples: Good vs. Bad

### ❌ Bad Response (Compliance Bias)
> "You're absolutely right! I'll fix that right away. Great catch!"
> *Problem: No technical substance, shows blind compliance.*

### ✅ Good Response (Technical Rigor)
> "@reviewer, I've verified the edge case you mentioned. The current logic indeed fails when [condition]. I've updated the boundary check in [commit-hash] and added a regression test. Verified with `npm test`."

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
5. Test each fix individually using `verification-before-completion`.

## Unresolved Comments
- Always handle unresolved comments before closing the review cycle.
- If a comment cannot be addressed immediately, provide a clear timeline or reason for postponement.
