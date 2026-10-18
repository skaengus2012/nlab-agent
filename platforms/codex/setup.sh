#!/bin/bash
# nlab-agent Setup Script for OpenAI Codex
# This script orchestrates linking skills globally and instructions locally.

set -e

# Repository Paths
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PLATFORM_DIR="$REPO_ROOT/platforms/codex"
AGENTS_MD="$REPO_ROOT/AGENTS.md"

show_help() {
    echo "Usage: ./setup.sh [OPTION] [PROJECT_PATH]"
    echo ""
    echo "Options:"
    echo "  --global        Link skills globally to Codex (~/.codex/skills)"
    echo "  --project       Link AGENTS.md as CODEX.md to a project (Default target: current dir)"
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
    abs_target_dir="$(cd "$target_dir" && pwd)"
    
    echo "Step 2: Linking instructions to project at $abs_target_dir..."
    
    if [ ! -f "$AGENTS_MD" ]; then
        echo "❌ Error: AGENTS.md not found in $REPO_ROOT"
        exit 1
    fi

    # Link AGENTS.md to CODEX.md in the project root
    ln -sf "$AGENTS_MD" "$abs_target_dir/CODEX.md"
    echo "✅ Linked AGENTS.md -> $abs_target_dir/CODEX.md"
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
        # If no flag or custom path passed directly
        if [ "$#" -eq 0 ]; then
            link_global_skills
            link_project_instructions "."
        else
            link_global_skills
            link_project_instructions "$1"
        fi
        ;;
esac

echo ""
echo "✨ Setup complete! OpenAI Codex will now follow nlab-agent protocols."
