# nlab-agent

Multi-agent orchestration protocols and platform-agnostic AI skills designed for AI coding assistants (Google Antigravity, Claude Code, OpenAI Codex, etc.).

## Project Structure

- `AGENTS.md`: Multi-agent orchestration rules, operating principles, and protocol definitions.
- `skills/`: Platform-agnostic AI skill definitions (Markdown with YAML frontmatter).
- `platforms/`: Platform-specific setup scripts and configurations (`antigravity`, `claude`, `codex`).
- `PERMISSIONS.md`: Tool execution permissions configuration for agent automation.
- `CONTRIBUTING.md`: **Core development guidelines and commit conventions (MUST follow).**

## Supported Platforms & Installation

Run the setup script corresponding to your agent environment:

### 🌌 Antigravity

Links skills globally (`~/.gemini/antigravity/skills/`), configures permissions, and sets up project protocols:

```bash
# Full setup (global skills + project protocols)
./platforms/antigravity/setup.sh

# Or global only
./platforms/antigravity/setup.sh --global

# Or link to a specific project directory
./platforms/antigravity/setup.sh --project /path/to/project
```

### 🤖 Claude Code

Links `AGENTS.md` as `CLAUDE.md` to establish project protocols for Claude Code:

```bash
# Link to current repository root (default)
./platforms/claude/setup.sh

# Or link to a specific project directory
./platforms/claude/setup.sh --project /path/to/project
```

### 💻 OpenAI Codex

Links skills globally (`~/.codex/skills/`) and creates `CODEX.md` in the target project:

```bash
# Full setup (global skills + project CODEX.md)
./platforms/codex/setup.sh

# Or global only
./platforms/codex/setup.sh --global

# Or link to a specific project directory
./platforms/codex/setup.sh --project /path/to/project
```

## Available Skills

| Category | Skills | Description |
| :--- | :--- | :--- |
| **📝 PM & Planning** | `writing-plans`, `brainstorming`, `create-gh-issue`, `create-requirements-analysis` | Task planning, architecture exploration, issue creation, and requirements analysis from issues. |
| **🛠 Engineering & Debugging** | `systematic-debugging`, `test-driven-development` | Hypothesis-driven root-cause debugging and TDD cycles. |
| **🛡 Quality & Workflow** | `requesting-code-review`, `receiving-code-review`, `verification-before-completion` | Evidence-based code reviews and pre-completion verification. |
| **🧠 Knowledge & Meta** | `writing-skills`, `skillify` | Creating, updating, and extracting reusable skills. |

## Adding New Skills

1. Create a new directory under `skills/<skill-name>/`.
2. Add a `SKILL.md` file with YAML frontmatter (`name`, `description`) and detailed workflow instructions.
3. Run the setup script for your platform to link the new skill.

## Contributing

Please review [CONTRIBUTING.md](CONTRIBUTING.md) before making changes. All commits must follow the repository convention:

```text
Implement/Fix/Chore IssueNumber - Description
```
