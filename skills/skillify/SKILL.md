---
name: skillify
description: Turn a repeatable workflow from the current session into a reusable Antigravity skill draft
---

# Skillify

## Goal
Capture a successful multi-step workflow discovered during a session into a concrete skill draft.

## Workflow
1. **Identify**: Detect a repeatable task successfully accomplished in the current session.
2. **Extract**:
   - Inputs and triggers.
   - Ordered steps taken.
   - Success criteria and verification methods.
   - Constraints and common pitfalls.
3. **Draft**: Output a complete `SKILL.md` file starting with YAML frontmatter.
4. **Register**: Add the new skill name to the appropriate category in `AGENTS.md`.
5. **Propose**: Suggest where the new skill should be saved (e.g., in `nlab-agent/skills/`).

## Rules
- Only capture workflows that are actually repeatable.
- Keep the skill practical and scoped.
- Prefer explicit success criteria over vague prose.

## Output
- Proposed skill name.
- Draft `SKILL.md` content.
- Instructions for installation using the `nlab-agent` setup script.
