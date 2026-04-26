---
name: finishing-a-development-branch
description: Use when implementation is complete and all tests pass - guides the final merge or PR process
---

# Finishing a Development Branch

## Process
1. **Verify Tests**: Run the full project test suite. If any fail, stop and fix.
2. **Review Options**: Decide how to integrate the work.
   - Option A: Merge locally and delete branch.
   - Option B: Push to remote and create a Pull Request.
   - Option C: Keep as-is for later.
3. **Execution**:
   - For PRs: Use `gh pr create` with a clear summary and test plan.
   - For Merges: Ensure the target branch is up-to-date first.

## PR Summary Template
- **Summary**: 2-3 bullets of what changed.
- **Test Plan**: Specific steps taken to verify the work.
- **Dependencies**: Any new libraries or required changes in other repos.
