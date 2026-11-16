#!/usr/bin/env bash
# Tests that platforms/claude/skills/ is linked by the Claude setup only.
# Runs the three link_skills.sh scripts against temporary directories; the real
# ~/.claude, ~/.codex and ~/.gemini are never touched.
# Usage: bash tests/claude-only-skills.test.sh
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0
ok()  { pass=$((pass + 1)); }
bad() { fail=$((fail + 1)); echo "FAIL: $1"; }
check() { if "${@:2}" >/dev/null 2>&1; then ok; else bad "$1"; fi; }

CLAUDE_ONLY="enter-worktree-on-claude-desktop"
SHARED="create-plans"

export HOME="$TMP/home"
export CLAUDE_HOME="$TMP/claude"
export CODEX_HOME="$TMP/codex"
mkdir -p "$HOME"

for platform in claude codex antigravity; do
    if ! bash "$REPO_ROOT/platforms/$platform/link_skills.sh" >/dev/null 2>&1; then
        bad "$platform: link_skills.sh failed"
    fi
done

CLAUDE_DIR="$CLAUDE_HOME/skills"
CODEX_DIR="$CODEX_HOME/skills"
AG_DIR="$HOME/.gemini/config/plugins/nlab-agent/skills"

# Claude links both the Claude-only skill and the shared skills (FR-3)
check "claude: $CLAUDE_ONLY is not linked" test -L "$CLAUDE_DIR/$CLAUDE_ONLY"
check "claude: $CLAUDE_ONLY link has no SKILL.md" test -f "$CLAUDE_DIR/$CLAUDE_ONLY/SKILL.md"
check "claude: shared skill $SHARED is not linked" test -f "$CLAUDE_DIR/$SHARED/SKILL.md"

# Codex and Antigravity never link the Claude-only skill (NFR-1)
check "codex: $CLAUDE_ONLY must not be linked" test ! -e "$CODEX_DIR/$CLAUDE_ONLY"
check "antigravity: $CLAUDE_ONLY must not be linked" test ! -e "$AG_DIR/$CLAUDE_ONLY"

# Shared skills keep working on the other platforms (FR-4 regression)
check "codex: shared skill $SHARED is not linked" test -f "$CODEX_DIR/$SHARED/SKILL.md"
check "antigravity: shared skill $SHARED is not linked" test -f "$AG_DIR/$SHARED/SKILL.md"

# Names must not collide, since Claude-only skills would shadow shared ones
for dir in "$REPO_ROOT"/platforms/claude/skills/*/; do
    name="$(basename "$dir")"
    check "name collision: $name exists in skills/ too" test ! -e "$REPO_ROOT/skills/$name"
done

echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
