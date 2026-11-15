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
    echo "  --global        Link skills globally to Claude Code (~/.claude/skills) and apply PERMISSIONS.md to ~/.claude/settings.json"
    echo "  --project       Link AGENTS.md as CLAUDE.md to a project"
    echo "  --all           Perform both global and project setup (Default)"
    echo "  --help          Show this help message"
}

# Apply the PERMISSIONS.md blocks to Claude Code's user-level permission settings.
# A failure here only skips the permissions; skills and instructions are still set up.
apply_permissions() {
    local target="${CLAUDE_HOME:-$HOME/.claude}/settings.json"
    echo "Step 1.1: Applying PERMISSIONS.md to Claude Code ($target)..."
    if ! command -v python3 >/dev/null 2>&1; then
        echo "⚠️ Warning: python3 not found. Skipping permission configuration."
        return 0
    fi
    python3 "$REPO_ROOT/platforms/lib/permissions.py" claude "$target" "$REPO_ROOT/PERMISSIONS.md" \
        || echo "⚠️ Warning: permissions were not applied (see the message above). Skills and instructions are not affected."
}

link_global_skills() {
    if [ -f "$PLATFORM_DIR/link_skills.sh" ]; then
        bash "$PLATFORM_DIR/link_skills.sh"
        apply_permissions
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

echo ""
echo "✨ Setup complete! Claude will now follow nlab-agent protocols."
