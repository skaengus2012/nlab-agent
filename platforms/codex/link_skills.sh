#!/bin/bash
set -e

# Repository Paths
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"

# Codex Global Path
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CODEX_SKILLS_DIR="$CODEX_HOME/skills"

echo "Step 1: Linking skills globally to Codex..."
mkdir -p "$CODEX_SKILLS_DIR"

# Clean up broken or stale symlinks in CODEX_SKILLS_DIR
echo "Cleaning up broken or stale symlinks..."
for link in "$CODEX_SKILLS_DIR"/*; do
    if [ -L "$link" ] && [ ! -e "$link" ]; then
        echo "Removing obsolete skill link: $(basename "$link")"
        rm -f "$link"
    fi
done

for skill_dir in "$SKILLS_SRC"/*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        echo "Linking skill: $skill_name"
        ln -sf "$skill_dir" "$CODEX_SKILLS_DIR/"
    fi
done

echo "✅ Global skills linked successfully to $CODEX_SKILLS_DIR."
