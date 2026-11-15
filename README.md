# nlab-agent

Multi-agent orchestration protocols and platform-agnostic AI skills designed for AI coding assistants (Google Antigravity, Claude Code, OpenAI Codex, etc.).

## Project Structure

- `AGENTS.md`: Multi-agent orchestration rules, operating principles, and protocol definitions.
- `skills/`: Platform-agnostic AI skill definitions (Markdown with YAML frontmatter).
- `platforms/`: Platform-specific setup scripts and configurations (`antigravity`, `claude`, `codex`).
- `PERMISSIONS.md`: Tool execution permissions configuration for agent automation.
- `CONTRIBUTING.md`: Development guidelines and commit conventions.

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

Links skills globally (`~/.claude/skills/`), applies the permission rules of `PERMISSIONS.md` to `~/.claude/settings.json`, and links `AGENTS.md` as `CLAUDE.md` to establish project protocols for Claude Code:

```bash
# Link to current repository root (default)
./platforms/claude/setup.sh

# Or link to a specific project directory
./platforms/claude/setup.sh --project /path/to/project
```

### 💻 OpenAI Codex

Links skills globally (`~/.codex/skills/`), writes the permission rules of `PERMISSIONS.md` to `~/.codex/rules/nlab-agent.rules`, and creates `CODEX.md` in the target project:

```bash
# Full setup (global skills + project CODEX.md)
./platforms/codex/setup.sh

# Or global only
./platforms/codex/setup.sh --global

# Or link to a specific project directory
./platforms/codex/setup.sh --project /path/to/project
```

### Permission settings written by setup

The global step of each setup script applies the `auto-allow` and `prompt-required` blocks of [PERMISSIONS.md](PERMISSIONS.md) to your user-level settings, so they affect every project the agent works in. That file lists what each platform receives.

- **Claude Code**: entries are added to `permissions.allow` and `permissions.ask` in `~/.claude/settings.json` (or `$CLAUDE_HOME/settings.json`). Your other settings and rules are kept and nothing is removed. A settings file that is not valid JSON is left untouched and setup prints a warning.
- **Codex**: `~/.codex/rules/nlab-agent.rules` (or `$CODEX_HOME/rules/`) is rewritten on every run. Codex treats `allow` as "run outside the sandbox without prompting", so review the `auto-allow` list before running setup.
- **Undo**: for Codex delete the rules file. For Claude Code remove the rules that setup added from `~/.claude/settings.json`; setup does not track which entries are its own.

## Available Skills

| Category | Skills | Description |
| :--- | :--- | :--- |
| **📝 PM & Planning** | `create-plans`, `brainstorming`, `create-gh-issue`, `create-gh-issue-analysis-report` | Task planning, architecture exploration, issue creation, and requirements analysis reports from GitHub issues. |
| **🛠 Engineering & Debugging** | `systematic-debugging`, `test-driven-development` | Hypothesis-driven root-cause debugging and TDD cycles. |
| **🛡 Quality & Workflow** | `requesting-code-review`, `receiving-code-review`, `verification-before-completion` | Evidence-based code reviews and pre-completion verification. |
| **🧠 Knowledge & Meta** | `writing-skills`, `skillify` | Creating, updating, and extracting reusable skills. |

## Adding New Skills

1. Create a new directory under `skills/<skill-name>/`.
2. Add a `SKILL.md` file with YAML frontmatter (`name`, `description`) and detailed workflow instructions.
3. Run the setup script for your platform to link the new skill.

## Contributing

Please review [CONTRIBUTING.md](CONTRIBUTING.md) before making changes. Commit subjects use the repository convention:

```text
Implement/Fix/Chore IssueNumber - Description
```
