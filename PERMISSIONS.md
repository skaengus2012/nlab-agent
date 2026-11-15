# Global Permission Grants (PERMISSIONS.md)

This file defines the global command permission grants allowed in the developer agent environments (such as Antigravity, Claude Code, Cursor, etc.) during the development and automation of the `nlab-agent` repository.

Each platform setup script reads the `auto-allow` and `prompt-required` blocks below and applies them to that platform's user-level permission settings. The settings therefore reach every project the agent works in, not only this repository.

| Platform | Written by | Destination | `auto-allow` | `prompt-required` |
|---|---|---|---|---|
| Antigravity | `platforms/antigravity/setup.sh` | `~/.gemini/config/config.json` | `globalPermissionGrants.allow` | not applied (commands outside `auto-allow` prompt by default) |
| Claude Code | `platforms/claude/setup.sh` | `~/.claude/settings.json` | `permissions.allow` | `permissions.ask` |
| Codex | `platforms/codex/setup.sh` | `~/.codex/rules/nlab-agent.rules` | `prefix_rule(..., decision="allow")` | `prefix_rule(..., decision="prompt")` |

Setup only adds entries to an existing Claude Code or Antigravity settings file and never removes what you or an earlier run put there. The Codex rules file belongs to nlab-agent and is rewritten on every run. When both blocks match a command, the decision that asks for approval wins in Claude Code (`ask` over `allow`) and in Codex (`prompt` over `allow`).

Codex's `allow` means "run outside the sandbox without prompting", which is stronger than Claude Code's `allow` (skip the prompt, keep the sandbox settings). Review the `auto-allow` list with that in mind.

---

## 1. Auto-Allowed Commands (Bypass Prompts)

The following commands are safe, read-only, or local-only mutation commands. They are automatically configured to skip interactive permission prompts for development convenience.

```permissions:auto-allow
find
cat
git status
git log
git show
git diff
git branch
git tag
git blame
git rev-parse
git add
git commit
git restore
git stash
git checkout
git switch
git rebase
git merge
git reset
git cherry-pick
git clean
git config
git fetch
git pull
git clone
git remote
gh pr view
gh pr list
gh pr diff
gh pr checks
gh pr status
gh pr create
gh pr comment
gh issue
gh api
gh repo view
gh auth status
```

---

## 2. Interactive/Prompt-Required Commands (Ask Every Time)

The following commands change the remote repository or its settings, which cannot be undone from the local clone, so the agent asks for user approval on each execution, even if documented below.

```permissions:prompt-required
git push
gh repo create
gh repo delete
gh pr merge
```
