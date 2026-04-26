---
name: create-gh-issue
description: Use when you need to create a new GitHub issue using the `gh` CLI. Ensures issues are created with proper formatting, labels, and context.
---

# Create GitHub Issue

## Overview
This skill ensures that all GitHub issues created within this repository follow a consistent format and include necessary metadata for better tracking and automation. **All content (Title and Body) must be written in English.**

## When to Use
- **Bug Reporting**: When a bug is discovered that requires tracking.
- **Feature Proposals**: When a new feature idea needs to be documented and discussed.
- **Task Management**: When breaking down a large task into smaller, trackable items.
- **Documentation**: When documentation gaps are identified.

## Core Instructions
1. **Title**: Use a clear, concise title. Prefix with a category in brackets, e.g., `[Bug]`, `[Feature]`, `[Task]`, `[Docs]`.
2. **Body**: 
   - Use Markdown for formatting.
   - **Problem**: Clearly define the issue or the current gap.
   - **Needs**: List what is required to solve the problem or the desired outcome.
   - Include relevant files or code snippets if necessary.
   - **Formatting**: Do NOT use `\n` literal strings in the command. Instead, use a multi-line string or save the body to a temporary file and use the `--body-file` flag for reliable formatting.
3. **Labels**: Always assign at least one relevant label. **Verify that the label exists** in the repository using `gh label list` before running the create command.
4. **Project/Milestone**: (Optional) Assign to a project or milestone if applicable.

## Red Flags
- Creating issues with vague titles like "Fix bug".
- Forgetting to add labels or using non-existent labels.
- Using literal `\n` in the body string, which leads to unreadable issues.
- Creating an issue without checking if a duplicate already exists.

## Example (Recommended approach)
```bash
# 1. Create a temporary body file
cat <<EOF > issue_body.md
### Problem
Currently, there is no standardized way to create issues through Antigravity skills.

### Needs
- A new skill `create-gh-issue` defining a clear template.
EOF

# 2. Create the issue using the file
gh issue create \
  --title "[Feature] Add GitHub Issue Creation Skill" \
  --body-file issue_body.md \
  --label "enhancement"

# 3. Cleanup
rm issue_body.md
```
