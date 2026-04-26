---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch a code-reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process.

## When to Request Review
- After each task in subagent-driven development.
- After completing a major feature.
- Before merging to the main branch.

## How to Request
1. **Get git SHAs:**
   ```bash
   BASE_SHA=$(git rev-parse HEAD~1)
   HEAD_SHA=$(git rev-parse HEAD)
   ```
2. **Review Criteria:**
   - Verify logic correctness.
   - Check for edge cases and error handling.
   - Ensure code follows project standards and architectural patterns.
   - Check for potential regressions.

3. **Act on feedback:**
   - Fix **Critical** issues immediately.
   - Fix **Important** issues before proceeding.
   - Note **Minor** issues for later or fix if trivial.

## Reviewer Guidelines (When you are the Reviewer)
When tasked with performing a code review, the agent must adhere to the following standards:
1. **Line-Level Feedback**: Always attach comments to specific code lines using `gh api` or equivalent line-targeting tools. Do not group multiple separate issues into a single general PR comment.
2. **Technical Focus**: Prioritize logic correctness, edge cases, and performance. Avoid generic praise or "fluff."
3. **Accuracy**: Use `view_file` to confirm exact line numbers before posting comments to ensure the feedback is correctly anchored.
