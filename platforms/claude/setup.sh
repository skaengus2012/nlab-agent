#!/bin/bash

# nlab-agent Setup Script for Claude (Claude Code)
# This script links project-specific instructions for the Claude agent.

set -e

# Repository Paths
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AGENTS_MD="$REPO_ROOT/AGENTS.md"

show_help() {
    echo "Usage: ./setup.sh [OPTION] [PROJECT_PATH]"
    echo ""
    echo "Options:"
    echo "  --project       Link AGENTS.md as CLAUDE.md to a project (Default)"
    echo "  --help          Show this help message"
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
    --project)
        link_project_instructions "${2:-.}"
        ;;
    --help)
        show_help
        ;;
    *)
        link_project_instructions "${1:-.}"
        ;;
esac

echo ""
echo "✨ Setup complete! Claude will now follow nlab-agent protocols."
