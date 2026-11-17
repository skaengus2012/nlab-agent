#!/usr/bin/env bash
set -e

# Repository Paths
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
CLAUDE_ONLY_SKILLS_SRC="$REPO_ROOT/platforms/claude/skills"

# Claude Code Global Path
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
CLAUDE_SKILLS_DIR="$CLAUDE_HOME/skills"

# A Claude-only skill sharing a name with a shared skill would silently replace its link
for skill_dir in "$CLAUDE_ONLY_SKILLS_SRC"/*; do
    if [ -d "$skill_dir" ] && [ -e "$SKILLS_SRC/$(basename "$skill_dir")" ]; then
        echo "❌ Error: skill name collision: $(basename "$skill_dir") exists in both skills/ and platforms/claude/skills/" >&2
        exit 1
    fi
done

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

# Shared skills first, then Claude-only skills (never linked by other platforms)
for skill_dir in "$SKILLS_SRC"/* "$CLAUDE_ONLY_SKILLS_SRC"/*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        echo "Linking skill: $skill_name"
        ln -sfn "$skill_dir" "$CLAUDE_SKILLS_DIR/$skill_name"
    fi
done

echo "✅ Global skills linked successfully to $CLAUDE_SKILLS_DIR."
