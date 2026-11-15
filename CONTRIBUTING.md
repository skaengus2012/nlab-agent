# Contributing Guidelines

This repository follows a specific set of rules for development and maintenance. All AI agents and contributors must adhere to these guidelines.

## Commit Message Convention

All commit messages follow this format. The `commit-msg` hook rejects other subjects once a setup script has enabled it (see Commit Message Hook), and the format applies whether or not the hook is enabled:

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
The format above is enforced by `.githooks/commit-msg`. Subjects that git generates are exempt: `Merge branch `, `Merge pull request `, `Merge remote-tracking branch `, `Merge tag `, `Merge commit `, `Revert "`, `Reapply "`, `fixup! `, `squash! `, and `amend! `. Other text that merely starts with `Merge ` or `Revert ` is not exempt. Git's own comment lines (`#` alone or `# ` followed by text) and leading blank lines are ignored when finding the subject, so a subject that starts with `#` directly followed by text is checked like any other. Subjects longer than 500 characters are rejected.

When you change the hook, run `bash tests/commit-msg.test.sh` and make sure it exits with 0. When you change the setup scripts, run `bash tests/setup-hook.test.sh` as well.

---

## AI Agent Instructions
- **Rule Enforcement**: The `commit-msg` hook enforces the commit message format only where a setup script has enabled it, so follow the format even when it is not enabled. Check this file for anything the hook does not cover.
- **Local Priority**: These rules are local to the `nlab-agent` repository and take precedence over global defaults.

## Enforcement Levels
Rules are enforced at the strongest level available, and prose is used only where nothing else can enforce them:
- **hook**: a rule that can be checked from its input, such as the commit message format.
- **instruction**: a rule that cannot be enforced by the above. State the reason instead of adding emphasis.
