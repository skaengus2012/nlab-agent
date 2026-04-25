#!/bin/bash

# Antigravity skills directory
ANTIGRAVITY_SKILLS_DIR="$HOME/.gemini/antigravity/skills"

# Create the directory if it doesn't exist
mkdir -p "$ANTIGRAVITY_SKILLS_DIR"

# Get the absolute path of the root skills directory (two levels up from agents/antigravity/)
SOURCE_SKILLS_DIR="$(cd "$(dirname "$0")/../../skills" && pwd)"

if [ ! -d "$SOURCE_SKILLS_DIR" ]; then
    echo "Error: skills directory not found at $SOURCE_SKILLS_DIR"
    exit 1
fi

echo "Linking skills from $SOURCE_SKILLS_DIR to $ANTIGRAVITY_SKILLS_DIR..."

for skill in "$SOURCE_SKILLS_DIR"/*; do
    if [ -d "$skill" ]; then
        skill_name=$(basename "$skill")
        echo "Linking $skill_name..."
        # Create a symbolic link (force overwrite if exists)
        ln -sf "$skill" "$ANTIGRAVITY_SKILLS_DIR/$skill_name"
    fi
done

echo "Done! Antigravity skills have been successfully linked."
