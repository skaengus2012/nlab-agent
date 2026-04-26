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
- Code reviews must be rigorous and evidence-driven, not performative.
- Use `deep-interview` to resolve ambiguity before starting high-effort tasks.
- Keep the `skills/` directory as the source of truth for all agent behaviors.
</working_agreements>

<state_management>
nlab-agent uses the `.nlab/` directory for persistent state and context preservation:
- `.nlab/state/` -- Mode-specific state files (JSON) for resuming interrupted tasks.
- `.nlab/plans/` -- Durable implementation plans and roadmaps.
- `.nlab/memory/` -- Project-level knowledge and decision logs.

**Requirement**: Before concluding any major phase, update the relevant state files to ensure the next session can resume with full context.
</state_management>

<model_resolution>
Apply the following model-tier mapping based on task complexity:
- **Strategic (Planning, Architecture, PM)**: Use high-reasoning models (e.g., Opus-tier) to ensure structural integrity.
- **Tactical (Implementation, Refactoring, Tests)**: Use balanced models (e.g., Sonnet-tier) for efficient and accurate coding.
- **Verification (QA, Linting, Simple Fixes)**: Use fast models (e.g., Haiku-tier) for rapid iteration cycles.

*Note: Antigravity should automatically adjust its "thought depth" based on these tiers.*
</model_resolution>

<skills>
## 📝 PM & Planning
- **`writing-plans`**: Create structured implementation plans with atomic, verifiable tasks.
- **`brainstorming`**: Facilitate divergent thinking for feature ideation and UX improvements.
- **`autoresearch`**: Automatically synthesize information from web searches and documentation.
- **`deep-interview`**: Use Socratic questioning to reduce ambiguity in requirements.

## 🛠 Engineering & Debugging
- **`systematic-debugging`**: Hypothesis-driven debugging for complex Android/Logic issues.
- **`autopilot`**: Execute multi-phase autonomous workflows for complex feature builds.
- **`test-driven-development`**: Ensure code correctness through Red-Green-Refactor cycles.
- **`finishing-a-development-branch`**: Guide the merge and PR process with structured options.

## 🛡 Quality & Workflow
- **`requesting-code-review`**: Dispatch a focused review subagent to catch regressions.
- **`receiving-code-review`**: Process feedback with technical rigor and reasoned pushback.
- **`verification-before-completion`**: Mandatory gate for evidence-backed completion claims.

## 🧠 Knowledge & Meta
- **`remember`**: Capture and organize session-persistent knowledge.
- **`writing-skills`**: TDD-based guide for creating high-quality new skills.
- **`skillify`**: Automatically transform successful workflows into reusable skill drafts.
</skills>

<cancellation>
If a task is blocked or the goal has changed, invoke the appropriate cancellation protocol to clear agent state and preserve logs.
</cancellation>
