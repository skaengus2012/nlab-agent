---
name: enter-worktree-on-claude-desktop
description: Claude desktop app ONLY. Use when the user wants to move the session into an EXISTING git worktree (e.g. "워크트리로 이동해줘", "워크트리 들어가줘", "/enter-worktree-on-claude-desktop"). Lists worktrees newest-first, lets the user pick one, and switches the session's working directory to it with the desktop app's `change_directory` tool. Does nothing outside the Claude desktop app.
---

# Enter Worktree (Claude desktop app only)

Switch the session's working directory into an existing git worktree. No arguments: the user always picks from a list.

## Step 0. Environment guard

This skill depends on the Claude desktop app's `change_directory` tool (`mcp__ccd_directory__change_directory`). It is usually deferred, so load it first with `ToolSearch` (query `select:mcp__ccd_directory__change_directory`).

If the tool cannot be found, **stop here**: tell the user this skill works only in the Claude desktop app, and do nothing else (no listing, no questions).

## Steps

1. **List worktrees sorted by creation time (newest first)**. Git does not store creation time, so use the birth time of each worktree's admin dir `<git-common-dir>/worktrees/<id>`:
   ```bash
   common=$(git rev-parse --path-format=absolute --git-common-dir)
   for d in "$common"/worktrees/*/; do
     p=$(sed 's#/\.git$##' "$d/gitdir")
     b=$(git -C "$p" branch --show-current 2>/dev/null)
     t=$(stat -f %B "$d")
     echo "$t $p [$b]"
   done | sort -rn
   ```
   The main checkout is not in this list; include it (from `git worktree list | head -1`) as the last entry.
2. **Ask the user to pick** with `AskUserQuestion`:
   - Options: the **2 newest** worktrees (label: branch name, description: path), plus **"전체 목록 보기"**.
   - "전체 목록 보기": print the whole sorted list (number, branch, path), then ask the user which one (they can answer by number or name).
   - If there are no worktrees, say so and stop.
3. **Switch the working directory**: call `change_directory` with the absolute path. Prefer it over `EnterWorktree`, which only tracks worktrees it created and is undone by `ExitWorktree`.
4. **Confirm in one line**: path and branch.

## Notes
- The switch takes effect only after the current turn ends; use absolute paths until then.
- Never create, remove, or modify worktrees with this skill.
