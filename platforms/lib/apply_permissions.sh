#!/usr/bin/env bash
# Sourced by platforms/{antigravity,claude,codex}/setup.sh. Expects REPO_ROOT to be set by the caller.

# Apply the PERMISSIONS.md blocks to a platform's user-level permission settings.
# Usage: apply_permissions <label> <claude|codex|antigravity> <target-file>
# A failure here only skips the permissions; skills and instructions are still set up.
apply_permissions() {
    local label="$1" kind="$2" target="$3"
    echo "Step 1.1: Applying PERMISSIONS.md to $label ($target)..."
    if ! command -v python3 >/dev/null 2>&1; then
        echo "⚠️ Warning: python3 not found. Skipping permission configuration."
        return 0
    fi
    python3 "$REPO_ROOT/platforms/lib/permissions.py" "$kind" "$target" "$REPO_ROOT/PERMISSIONS.md" \
        || echo "⚠️ Warning: permissions were not applied (see the message above). Skills and instructions are not affected."
}
