#!/bin/bash

# nlab-agent Setup Script for Antigravity
# This script links skills globally and instructions locally to a project.

set -e

# Repository Paths
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
AGENTS_MD="$REPO_ROOT/AGENTS.md"

# Antigravity Global Path
ANTIGRAVITY_SKILLS_DIR="$HOME/.gemini/antigravity/skills"

show_help() {
    echo "Usage: ./setup.sh [OPTION] [PROJECT_PATH]"
    echo ""
    echo "Options:"
    echo "  --global        Link skills globally to Antigravity (System-wide)"
    echo "  --project       Link AGENTS.md as CLAUDE.md to a project (Project-wide)"
    echo "  --all           Perform both global and project setup (Default)"
    echo "  --help          Show this help message"
}

link_global_skills() {
    echo "Step 1: Linking skills globally to Antigravity..."
    mkdir -p "$ANTIGRAVITY_SKILLS_DIR"
    
    for skill_dir in "$SKILLS_SRC"/*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            echo "Linking skill: $skill_name"
            ln -sf "$skill_dir" "$ANTIGRAVITY_SKILLS_DIR/"
        fi
    done
    echo "✅ Global skills linked successfully."
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
        link_project_instructions "$2"
        ;;
    --help)
        show_help
        ;;
    --all|*)
        link_global_skills
        link_project_instructions "$2"
        ;;
esac

echo ""
echo "✨ Setup complete! Antigravity will now follow nlab-agent protocols."
