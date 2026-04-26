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
3. **Labels**: Always assign at least one relevant label (e.g., `bug`, `enhancement`, `documentation`, `high-priority`).
4. **Project/Milestone**: (Optional) Assign to a project or milestone if applicable.

## Red Flags
- Creating issues with vague titles like "Fix bug".
- Forgetting to add labels.
- Creating an issue without checking if a duplicate already exists.

## Example
```bash
gh issue create \
  --title "[Feature] Add GitHub Issue Creation Skill" \
  --body "### Problem\nCurrently, there is no standardized way to create issues through Antigravity skills, leading to inconsistent and hard-to-read issues.\n\n### Needs\n- A new skill \`create-gh-issue\` defining a clear template.\n- Body must include 'Problem' and 'Needs' sections for human readability." \
  --label "enhancement"
```
