# nlab-agent

A collection of AI agent skills and instructions for Antigravity, Cursor, and more.

## Project Structure
- `skills/`: Platform-agnostic AI skill definitions (Markdown).
- `platforms/`: Platform-specific setup scripts and configurations.
  - `antigravity/`: Antigravity-specific setup.

## Installation

### For Antigravity
To link these skills to your Antigravity environment, run:
```bash
./platforms/antigravity/setup.sh
```

## Adding New Skills
1. Create a new directory in `skills/`.
2. Add a `SKILL.md` file with YAML frontmatter.
3. Run the setup script for your agent.
