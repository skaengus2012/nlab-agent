---
name: writing-skills
description: Use when creating or updating Antigravity skills. Applies TDD principles to documentation to ensure skills are effective and loophole-free.
---

# Writing Skills

## Core Principle: TDD for Skills
**No skill without a failing test first.** Before writing a skill, observe how the agent fails without it.

## The Cycle
1. **RED (Baseline)**: Run a scenario without the skill. Document exactly where the agent fails or rationalizes poor behavior.
2. **GREEN (Minimal Skill)**: Write the minimal instructions necessary to fix the observed failure.
3. **REFACTOR (Close Loopholes)**: Identify new rationalizations and add explicit counters (e.g., "No exceptions: Do not keep code as reference").

## Structure of a SKILL.md
- **YAML Frontmatter**: Must include `name` and `description`.
- **Overview**: Clear statement of the core principle.
- **When to Use**: Specific triggers and symptoms.
- **Red Flags**: List of common rationalizations to stop and start over.
- **Example**: One high-quality, practical example.

## Red Flags - STOP and Start Over
- "It's too simple to need a skill."
- "I'll just remember this next time."
- "The spirit of the rule matters more than the ritual." (Spirit vs Letter)
