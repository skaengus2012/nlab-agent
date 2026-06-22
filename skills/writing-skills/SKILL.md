---
name: writing-skills
description: Use when creating or updating Antigravity skills. Applies TDD principles to documentation to ensure skills are effective and loophole-free.
---

# Writing Skills

## Core Principle: TDD for Skills
**No skill without a failing test first.** Before writing a skill, observe how the agent fails without it.

## Designing Interactive Skills
Any skill that requires multiple inputs from the user (e.g., creating issues, writing plans) must strictly adhere to the following dialog control principles:
1. **Single Query Rule**: Ask for exactly **one** pending field or clarification at a time. Do not request multiple inputs or combine optional prompts in a single turn.
2. **Sequential Progress Tracking**: Keep track of the current collection state in your inner monologue (e.g., `[Field A: Done], [Field B: Pending]`) and only query the first pending item.
3. **Smart Skip**: If the user proactively provides answers for multiple fields in a single message, mark all corresponding fields as completed and jump straight to the next pending field.
4. **Focused Prompting**: Keep the question concise and focused on the target field without mentioning future steps in the same turn.

## The Cycle
1. **RED (Baseline)**: Run a scenario without the skill (or using the snapshot of the old version). Document exactly where the agent fails, takes incorrect shortcuts, or rationalizes poor behavior.
2. **GREEN (Minimal Skill)**: Write the minimal, clear instructions necessary to fix the observed failure.
3. **VERIFY (Test & Benchmark)**: **Run the same scenario again with the new/modified skill enabled.** Compare the output qualitatively and quantitatively against the RED baseline. Ensure the failure is resolved and that the token/time overhead is justified.
4. **REFACTOR (Close Loopholes)**: Identify any new bypasses or rationalizations observed during verification and add explicit counters (e.g., "No exceptions: Do not keep code as reference").

## Progressive Disclosure & Architecture
To keep the context clean and prevent token bloat, organize skills into a three-level loading hierarchy:
1. **Metadata (Trigger)**: The YAML frontmatter containing `name` and `description`. Use a **Pushy Description** (e.g., explicitly direct the model to run the skill when specific keywords are mentioned to prevent undertriggering).
2. **SKILL.md Body (Core Guidelines)**: Keep the main markdown file under 500 lines. Focus on core workflows, rules, and example blocks.
3. **Bundled Resources (Details)**: Delegate extensive documentation, huge code templates, or deterministic execution to subdirectories:
   - `references/`: Loaded dynamically as needed (e.g., `aws.md`, `gcp.md`).
   - `scripts/`: Python/Shell scripts for running repetitive tasks deterministically.

## Structure of a SKILL.md
- **YAML Frontmatter**: Must include `name` and `description` (with pushy trigger words).
- **Overview**: Clear statement of the core principle.
- **When to Use**: Specific triggers and symptoms.
- **Red Flags**: List of common rationalizations to stop and start over.
- **Example**: One high-quality, practical example.

## Red Flags - STOP and Start Over
- "It's too simple to need a skill."
- "I'll just remember this next time."
- "The spirit of the rule matters more than the ritual." (Spirit vs Letter)
- Rationalizing that grouping questions into a single turn is "more efficient" for the user.
- Saving files directly in the main `SKILL.md` when they exceed 100 lines (violating Progressive Disclosure).

## Deployment Checklist
- [ ] Record the RED baseline behavior.
- [ ] Create/Update the `SKILL.md` file using the 3-level structure.
- [ ] Run verification tests to prove that the new skill successfully resolves the RED baseline.
- [ ] Register the new skill name in `AGENTS.md` under the correct category.
- [ ] Run the `setup.sh` script to link the new skill to Antigravity.
