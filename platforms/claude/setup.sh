#!/bin/bash

# nlab-agent Setup Script for Claude (Claude Code)
# This script links nlab-agent skills globally and project-specific instructions locally.

set -e

# Repository Paths
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AGENTS_MD="$REPO_ROOT/AGENTS.md"
PLATFORM_DIR="$REPO_ROOT/platforms/claude"

show_help() {
    echo "Usage: ./setup.sh [OPTION] [PROJECT_PATH]"
    echo ""
    echo "Options:"
    echo "  --global        Link skills globally to Claude Code (~/.claude/skills)"
    echo "  --project       Link AGENTS.md as CLAUDE.md to a project"
    echo "  --all           Perform both global and project setup (Default)"
    echo "  --help          Show this help message"
}

link_global_skills() {
    if [ -f "$PLATFORM_DIR/link_skills.sh" ]; then
        bash "$PLATFORM_DIR/link_skills.sh"
    else
        echo "❌ Error: link_skills.sh not found at $PLATFORM_DIR"
        exit 1
    fi
}

link_project_instructions() {
    local target_dir="${1:-.}"
    local abs_target_dir

    # If target_dir is relative, make it absolute relative to the current working directory
    # If target_dir is '.', it uses the current directory where the script is called.
    # However, usually we want to link it to the REPO_ROOT if no path is provided.

    if [ "$target_dir" == "." ]; then
        abs_target_dir="$REPO_ROOT"
    else
        abs_target_dir="$(cd "$target_dir" && pwd)"
    fi

    echo "Linking instructions to project at $abs_target_dir..."

    if [ ! -f "$AGENTS_MD" ]; then
        echo "❌ Error: AGENTS.md not found in $REPO_ROOT"
        exit 1
    fi

    # Link AGENTS.md to CLAUDE.md in the project root
    ln -sf "$AGENTS_MD" "$abs_target_dir/CLAUDE.md"
    echo "✅ Linked AGENTS.md -> $abs_target_dir/CLAUDE.md"
}

# Enable the repository's commit-msg hook (CONTRIBUTING.md). Applies only to this repository.
enable_commit_hook() {
    local real_root top current
    real_root="$(cd "$REPO_ROOT" && pwd -P)"
    top="$(git -C "$REPO_ROOT" rev-parse --show-toplevel 2>/dev/null || true)"

    # Skip when this is not the root of a git repository (e.g. a zip download or a nested checkout).
    if [ -z "$top" ] || [ "$(cd "$top" && pwd -P)" != "$real_root" ]; then
        echo "skip: $REPO_ROOT is not a git repository root, commit-msg hook not enabled"
        return 0
    fi

    current="$(git -C "$REPO_ROOT" config --local --get core.hooksPath || true)"
    if [ -n "$current" ] && [ "$current" != ".githooks" ]; then
        echo "⚠️ Warning: core.hooksPath is already set to '$current'. Leaving it unchanged; commit-msg hook not enabled."
        return 0
    fi

    [ -f "$REPO_ROOT/.githooks/commit-msg" ] && chmod +x "$REPO_ROOT/.githooks/commit-msg"
    git -C "$REPO_ROOT" config core.hooksPath .githooks
    echo "✅ Enabled commit-msg hook (core.hooksPath = .githooks)"
}

# Parse Arguments
case "$1" in
    --global)
        link_global_skills
        ;;
    --project)
        link_project_instructions "${2:-.}"
        ;;
    --help)
        show_help
        exit 0
        ;;
    --all)
        link_global_skills
        link_project_instructions "${2:-.}"
        ;;
    *)
        link_global_skills
        link_project_instructions "${1:-.}"
        ;;
esac

enable_commit_hook

echo ""
echo "✨ Setup complete! Claude will now follow nlab-agent protocols."
