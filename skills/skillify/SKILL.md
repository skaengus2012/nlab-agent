---
name: skillify
description: Turn a repeatable workflow from the current session into a reusable Antigravity skill draft. Make sure to trigger this skill whenever the user says 'turn this into a skill', 'save this workflow', or when you identify a successful multi-step workflow in the current session that could be generalized, even if they do not explicitly ask for 'skillify'.
---

# Skillify

## Goal
Capture a successful multi-step workflow discovered during a session into a concrete skill draft.

## Interactive Skill Extraction
When a successful workflow is identified and recommended as a new skill, negotiate the scope and details with the user step-by-step using the following flow:
1. **Single Query Rule**: Ask only **one** question at a time during the negotiation.
2. **Sequential Progress Tracking**: Keep track of the skill design components in your inner monologue (e.g., `[Name/Goal: Pending], [Inputs/Outputs: Pending]`) and query only the first pending item.
3. **Smart Skip**: If the user proactively defines the name, inputs, and triggers in a single response, mark them as completed and proceed straight to drafting the steps.
4. **Focused Prompting**: Keep each question concise and focused on the target skill component.
5. **Present the Draft**: Compile the negotiated details and generate the final `SKILL.md` file.

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
