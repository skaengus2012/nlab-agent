# nlab-agent - Multi-Agent Orchestration & Capabilities

This repository defines the core capabilities, operating protocols, and state-management rules for AI agents working on Android development and Product Management.

<operating_principles>
- **Plan before action**: Every complex task must begin with a structured plan (`writing-plans`).
- **Evidence over assumptions**: Never claim completion without running verification (`verification-before-completion`).
- **Context preservation**: Keep the decision-making history intact using project memory (`remember`).
- **Role-switching**: Seamlessly transition between PM (Strategic) and Developer (Tactical) perspectives.
- **Root-cause focus**: Use systematic debugging to find the source, not just fix the symptom.
</operating_principles>

<working_agreements>
- All implementation work must follow the TDD cycle when applicable.
- Code reviews must be rigorous and evidence-driven.
- Use `deep-interview` to resolve ambiguity before starting high-effort tasks.
- **Source of Truth**: The `skills/` directory is the primary source of truth. Always browse it to discover the latest tools.
</working_agreements>

<state_management>
nlab-agent uses the `.nlab/` directory for persistent state:
- `.nlab/state/` -- Mode state files (JSON).
- `.nlab/plans/` -- Implementation plans.
- `.nlab/memory/` -- Project decision logs.
</state_management>

<model_resolution>
- **Strategic (PM/Arch)**: Use high-reasoning models (Opus-tier).
- **Tactical (Coding)**: Use balanced models (Sonnet-tier).
- **Verification (QA)**: Use fast models (Haiku-tier).
</model_resolution>

<skills>
The following is a high-level map of available skill categories. **Always check the `skills/` directory for the full list and latest documentation.**

### 📝 PM & Planning
- `writing-plans`, `brainstorming`, `autoresearch`, `deep-interview`

### 🛠 Engineering & Debugging
- `systematic-debugging`, `autopilot`, `test-driven-development`, `finishing-a-development-branch`, `create-gh-issue`

### 🛡 Quality & Workflow
- `requesting-code-review`, `receiving-code-review`, `verification-before-completion`

### 🧠 Knowledge & Meta
- `remember`, `writing-skills`, `skillify`
</skills>

<cancellation>
Invoke cancellation protocols to clear agent state and preserve logs if a task is blocked.
</cancellation>
