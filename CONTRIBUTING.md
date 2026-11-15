# Contributing Guidelines

This repository follows a specific set of rules for development and maintenance. All AI agents and contributors must adhere to these guidelines.

## Commit Message Convention

All commit messages follow this format, and the `commit-msg` hook rejects other subjects:

`Implement/Fix/Chore IssueNumber - Description`

- If an issue number exists, use the `#` prefix (e.g., `#12`).
- If no issue number exists, use `N/A` without the `#` prefix.

### Category Definitions:
- **Implement**: Used for adding new features, skills, or significant functionality.
- **Fix**: Used for bug fixes, correcting instructions, or fixing broken links.
- **Chore**: Used for maintenance tasks, updating configurations, or simple documentation cleanup that doesn't affect logic.

### Example:
`Implement #12 - Add deep-research skill for advanced analysis`
`Implement N/A - Create local agent guidelines`
`Fix #5 - Correct typo in setup.sh path`
`Chore N/A - Update README documentation`

## Commit Message Hook
The format above is enforced by `.githooks/commit-msg`. Subjects that start with `Merge `, `Revert `, `fixup!`, or `squash!` are exempt, and `#` comment lines and leading blank lines are ignored when finding the subject.

When you change the hook, run `bash tests/commit-msg.test.sh` and make sure it exits with 0.

---

## AI Agent Instructions
- **Rule Enforcement**: The `commit-msg` hook enforces the commit message format. Check this file for anything the hook does not cover.
- **Local Priority**: These rules are local to the `nlab-agent` repository and take precedence over global defaults.

## Enforcement Levels
Rules are enforced at the strongest level available, and prose is used only where nothing else can enforce them:
- **deny**: a command that can be statically blocked (Claude Code `permissions.deny`).
- **ask**: a command that needs the user's approval every time (Claude Code `permissions.ask`).
- **hook**: a rule that can be checked from its input, such as the commit message format.
- **instruction**: a rule that cannot be enforced by the above. State the reason instead of adding emphasis.
