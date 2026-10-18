#!/bin/bash
set -e

# Repository Paths
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"

# Antigravity Global Path
ANTIGRAVITY_PLUGIN_DIR="$HOME/.gemini/config/plugins/nlab-agent"
ANTIGRAVITY_SKILLS_DIR="$ANTIGRAVITY_PLUGIN_DIR/skills"

echo "Step 1: Linking skills globally to Antigravity..."
mkdir -p "$ANTIGRAVITY_SKILLS_DIR"

# Create plugin.json if it doesn't exist
if [ ! -f "$ANTIGRAVITY_PLUGIN_DIR/plugin.json" ]; then
    echo "Creating plugin.json..."
    cat << 'EOF' > "$ANTIGRAVITY_PLUGIN_DIR/plugin.json"
{
  "name": "nlab-agent",
  "version": "1.0.0",
  "description": "NLab Agent Skills",
  "author": {
    "name": "NLab"
  },
  "license": "Apache-2.0",
  "keywords": [
    "nlab",
    "skills"
  ]
}
EOF
fi

# Clean up broken or stale symlinks in ANTIGRAVITY_SKILLS_DIR
echo "Cleaning up broken or stale symlinks..."
for link in "$ANTIGRAVITY_SKILLS_DIR"/*; do
    if [ -L "$link" ] && [ ! -e "$link" ]; then
        echo "Removing obsolete skill link: $(basename "$link")"
        rm -f "$link"
    fi
done

for skill_dir in "$SKILLS_SRC"/*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        echo "Linking skill: $skill_name"
        ln -sf "$skill_dir" "$ANTIGRAVITY_SKILLS_DIR/"
    fi
done
echo "✅ Global skills linked successfully."
