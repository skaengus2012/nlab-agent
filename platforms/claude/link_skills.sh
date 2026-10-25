#!/bin/bash
set -e

# Repository Paths
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"

# Claude Code Global Path
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
CLAUDE_SKILLS_DIR="$CLAUDE_HOME/skills"

echo "Step 1: Linking skills globally to Claude Code..."
mkdir -p "$CLAUDE_SKILLS_DIR"

# Clean up broken or stale symlinks in CLAUDE_SKILLS_DIR
echo "Cleaning up broken or stale symlinks..."
for link in "$CLAUDE_SKILLS_DIR"/*; do
    if [ -L "$link" ] && [ ! -e "$link" ]; then
        echo "Removing obsolete skill link: $(basename "$link")"
        rm -f "$link"
    fi
done

for skill_dir in "$SKILLS_SRC"/*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        echo "Linking skill: $skill_name"
        ln -sfn "$skill_dir" "$CLAUDE_SKILLS_DIR/$skill_name"
    fi
done

echo "✅ Global skills linked successfully to $CLAUDE_SKILLS_DIR."
