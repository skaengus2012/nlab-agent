---
name: enter-worktree-on-claude-desktop
description: Claude desktop app ONLY. Use when the user wants to move the session into an EXISTING git worktree (e.g. "워크트리로 이동해줘", "워크트리 들어가줘", "/enter-worktree-on-claude-desktop"). Lists the worktrees, lets the user pick one, and switches the session's working directory to it with the desktop app's `change_directory` tool. Does nothing outside the Claude desktop app.
---

# Enter Worktree (Claude desktop app only)

Switch the session's working directory into an existing git worktree. No arguments: the user always picks from a list.

## Step 0. Environment guard

This skill depends on the Claude desktop app's `change_directory` tool (`mcp__ccd_directory__change_directory`). It is usually deferred, so load it first with `ToolSearch` (query `select:mcp__ccd_directory__change_directory`).

If the tool cannot be found, **stop here**: tell the user this skill works only in the Claude desktop app, and do nothing else (no listing, no questions).

## Steps

1. **List worktrees** in the order `git worktree list --porcelain` gives (the main checkout first). Print one `path<TAB>branch` line per worktree, skipping prunable (already deleted) and bare entries, and labelling a detached HEAD `(detached)`:
   ```bash
   git worktree list --porcelain | awk '
     /^worktree /{ if (p != "" && !skip) print p "\t" b; p = substr($0, 10); b = "(detached)"; skip = 0; next }
     /^branch /{ b = $2; sub("refs/heads/", "", b) }
     /^(prunable|bare)/{ skip = 1 }
     END { if (p != "" && !skip) print p "\t" b }'
   ```
2. **Ask the user to pick** with `AskUserQuestion`:
   - Label: the branch name, or the directory name for `(detached)`. Description: the path.
   - Up to 4 entries: make each an option. More than 4: the first 3 plus **"전체 목록 보기"**, which prints the whole list (number, branch, path) and asks which one (by number or name).
   - If the list is empty, say so and stop.
3. **Switch the working directory**: call `change_directory` with the absolute path. Prefer it over `EnterWorktree`, which only tracks worktrees it created and is undone by `ExitWorktree`.
4. **Confirm in one line**: path and branch.

## Notes
- The switch takes effect only after the current turn ends; use absolute paths until then.
- Never create, remove, or modify worktrees with this skill.
