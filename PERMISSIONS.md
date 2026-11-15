# Global Permission Grants (PERMISSIONS.md)

This file defines the global command permission grants allowed in the developer agent environments (such as Antigravity, Claude Code, Cursor, etc.) during the development and automation of the `nlab-agent` repository.

Platform-specific setup scripts parse this file and apply configurations to their respective local settings.

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

The following commands reach remote systems or are hard to undo, so the agent asks for user approval on each execution, even if documented below.

```permissions:prompt-required
git fetch
git pull
git push
git clone
git remote
gh repo create
gh repo delete
gh pr merge
```
