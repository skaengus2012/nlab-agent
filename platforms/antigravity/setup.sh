#!/bin/bash
# nlab-agent Setup Script for Antigravity
# This script orchestrates linking skills globally and instructions locally.

set -e

# Repository Paths
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PLATFORM_DIR="$REPO_ROOT/platforms/antigravity"
AGENTS_MD="$REPO_ROOT/AGENTS.md"

# Antigravity Global Path
CONFIG_JSON="$HOME/.gemini/config/config.json"
PERMISSIONS_MD="$REPO_ROOT/PERMISSIONS.md"

show_help() {
    echo "Usage: ./setup.sh [OPTION] [PROJECT_PATH]"
    echo ""
    echo "Options:"
    echo "  --global        Link skills globally to Antigravity and configure permissions"
    echo "  --project       Link AGENTS.md as CLAUDE.md to a project (Project-wide)"
    echo "  --all           Perform both global and project setup (Default)"
    echo "  --help          Show this help message"
}

link_global_skills() {
    # 1. Run skill symlink script
    if [ -f "$PLATFORM_DIR/link_skills.sh" ]; then
        bash "$PLATFORM_DIR/link_skills.sh"
    else
        echo "❌ Error: link_skills.sh not found at $PLATFORM_DIR"
        exit 1
    fi

    # 2. Run permission configuration script
    echo "Step 1.1: Configuring global permissions from PERMISSIONS.md..."
    if command -v python3 >/dev/null 2>&1; then
        if [ -f "$PLATFORM_DIR/configure_permissions.py" ]; then
            python3 "$PLATFORM_DIR/configure_permissions.py" "$CONFIG_JSON" "$PERMISSIONS_MD"
        else
            echo "❌ Error: configure_permissions.py not found at $PLATFORM_DIR"
            exit 1
        fi
    else
        echo "⚠️ Warning: python3 not found. Skipping global permission configuration."
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
