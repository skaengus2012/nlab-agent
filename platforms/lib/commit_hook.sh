#!/usr/bin/env bash
# Sourced by platforms/*/setup.sh. Expects REPO_ROOT to be set by the caller.

# Enable the repository's commit-msg hook (CONTRIBUTING.md). Applies only to this repository.
# Setting core.hooksPath replaces .git/hooks and any global hooks path, so it is skipped with a
# warning when that would silently disable a hook the user already relies on.
enable_commit_hook() {
    local real_root top current global_path common existing
    real_root="$(cd "$REPO_ROOT" && pwd -P)"
    top="$(git -C "$REPO_ROOT" rev-parse --show-toplevel 2>/dev/null || true)"

    # Skip when this is not the root of a git repository (e.g. a zip download or a nested checkout).
    if [ -z "$top" ] || [ "$(cd "$top" && pwd -P)" != "$real_root" ]; then
        echo "skip: $REPO_ROOT is not a git repository root, commit-msg hook not enabled"
        return 0
    fi

    if [ ! -f "$REPO_ROOT/.githooks/commit-msg" ]; then
        echo "skip: .githooks/commit-msg not found, commit-msg hook not enabled"
        return 0
    fi

    current="$(git -C "$REPO_ROOT" config --local --get core.hooksPath || true)"
    if [ -n "$current" ] && [ "$current" != ".githooks" ]; then
        echo "⚠️ Warning: core.hooksPath is already set to '$current'. Leaving it unchanged; commit-msg hook not enabled."
        return 0
    fi

    global_path="$(git config --global --get core.hooksPath || true)"
    if [ -n "$global_path" ]; then
        echo "⚠️ Warning: a global core.hooksPath ('$global_path') is set and would stop running in this repository. Leaving it unchanged; commit-msg hook not enabled."
        return 0
    fi

    common="$(cd "$REPO_ROOT" && cd "$(git rev-parse --git-common-dir)" && pwd -P)"
    existing="$(find "$common/hooks" -maxdepth 1 -type f -perm -u+x ! -name '*.sample' 2>/dev/null | head -n 1)"
    if [ -n "$existing" ]; then
        echo "⚠️ Warning: $existing exists and would stop running once .githooks is used. Leaving it unchanged; commit-msg hook not enabled."
        return 0
    fi

    chmod +x "$REPO_ROOT/.githooks/commit-msg"
    git -C "$REPO_ROOT" config core.hooksPath .githooks
    echo "✅ Enabled commit-msg hook (core.hooksPath = .githooks)"
}
