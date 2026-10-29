---
name: create-requirements-analysis
description: Use when you need to turn a tracked requirement (GitHub issue, Jira ticket, etc.) into a requirements analysis document. Takes an issue/ticket ID, reads its body, comments, and parent item from the project's requirements source, and generates a requirements analysis document inside the project. Make sure to use this skill whenever the user asks to analyze requirements, organize an issue, or write a requirements document for an issue/ticket ID, even if they do not explicitly ask for 'create-requirements-analysis'.
---

# Requirements Analysis

## Overview
Requirements are commonly tracked in an issue tracker (GitHub issues, Jira, etc.). Item bodies are often thin or empty, and agreed details may live only in comments. This skill collects every source of requirements for one item and organizes them into a single document inside the repository.

**Input**: an issue/ticket ID (e.g. `869`, `PROJ-123`). If the user did not provide one, ask for it.

**Output**: the document location defined by the project rules (see Step 0), saved as a single file per item.

**Language**: Write the document (including headings) in the language the project rules or the user require. Code blocks, file paths, and commands stay in English. The template below uses English headings; translate them as needed.

## When to Use
- The user gives an issue/ticket ID and asks to analyze or organize its requirements.
- Before implementation, when the item body alone is not enough to start.
- After new comments change the agreed requirements of an existing document.

## Step 0. Resolve Project Rules
Before collecting sources, find out how this project wants requirements documents written.

1. Look in the project's `AGENTS.md` (or `CLAUDE.md`) for a requirements-analysis section, or for an index entry linking a related guideline file. Read it.
2. Extract these settings:
   - **Requirements source**: where requirements live and how to read them (e.g. GitHub issues via `gh`, Jira via a CLI or MCP tool, a docs folder)
   - **Output path** (e.g. `docs/spec/issue<number>/requirements.md`)
   - **Document language**
   - **Where to look when checking impact** (e.g. a module structure section)
   - **Template additions or omissions**, if any
3. Priority: the user's direct instruction > project rules > the settings the user gives in step 4.

### If no project rule is found
Do not guess. Ask the user, one question at a time, for the settings above. The requirements source, output path, and language are mandatory. Propose defaults they can accept: the tracker detected from `git remote` (GitHub) for the source, `docs/spec/issue<number>/requirements.md` for the path, and the item's language for the document.

### Propose making the rule discoverable
This applies to every setting, including the requirements source. After receiving the settings, recommend recording them in the project rules so that AI agents find them next time. Do not edit any file until the user approves.

- If the project already has a guidelines index (e.g. a table in `AGENTS.md` pointing to `docs/guidelines/*.md`), propose a new guideline file plus an index entry that says when to read it (e.g. "before writing a requirements analysis document").
- Otherwise, propose a short `## Requirements Analysis` section in `AGENTS.md` listing the settings.

Show the exact change you would make and apply it only after approval. Continue the analysis either way.

## Step 1. Collect Sources
Read the item's body, comments, labels, last-updated time, and parent item (parent issue, epic, etc.) from the requirements source resolved in Step 0, using the tool the project rules name. If the project rules do not name a tool and none is available, ask the user to paste the content; do not fabricate it.

### GitHub issues (example)
Use the repository of the current working directory.

```bash
# 1. Issue body, comments, labels, and parent reference
gh issue view <number> --comments

# 2. Structured data (to find the parent issue)
gh issue view <number> --json number,title,body,labels,state,comments,url,updatedAt
```

### Parent item
Read the parent item (e.g. the `parent:` field of a GitHub issue, a Jira epic) when **any** of the following holds:
- The body is empty or too thin to derive requirements.
- The body references the parent for background, goals, or scope.
- Terms or decisions in the issue are not explained anywhere else.

For GitHub: `gh issue view <parent-number> --comments`.

Do not follow the parent chain further than one level unless the user asks.

## Step 2. Analyze
Separate what the sources **state** from what you **infer**.

1. **Merge sources**: When the body and a comment conflict, the later comment wins. Note the conflict in the document.
2. **Extract requirements**: Turn each stated need into one verifiable statement. Give each an ID (`FR-1`, `NFR-1`).
3. **Incremental update**: If the document already exists, only analyze what changed after its `Analysis Baseline` (new comments, edited body). See Step 3.
4. **Mark uncertainty**: Anything not explicitly stated but required to proceed goes into *Open Questions*; never present guesses as requirements. A requirement's `Source` must be text actually stated in the body, a comment, or the parent issue. Do not list requirements inferred from conventions or intent (e.g. "follow the existing format") in the requirement tables; put them in *Open Questions* instead.
5. **Check the codebase when needed**: Look at related modules only to clarify impact scope. Do not design the implementation here.

If critical ambiguities remain, ask the user before writing the document.

## Step 3. Write the Document
Create the document at the output path resolved in Step 0 (create the directory if it does not exist).

### If the document already exists
The document always represents the **current state** of the requirements. Never append a new section after a `---` separator; edit in place.

1. Read the existing document and its `Analysis Baseline`.
2. Reflect only changes made after that point (new comments, edited body) by modifying the affected items directly.
3. Do not delete a dropped requirement or reuse its ID. Mark it as `~~FR-3~~ (Dropped: <reason>)`. New requirements take the next unused ID.
4. Remove resolved *Open Questions* from the section and record the resolution in `Change History`. Do not leave "resolved" items behind.
5. Re-check every status-dependent statement (e.g. "No conflicts, since there are no comments" in `Conflicts and Notes`) and rewrite it to match the current sources.
6. Update `Last Updated` and `Analysis Baseline`.
7. Add one row to `Change History` (date, what changed, source). Never rewrite past rows.
8. If nothing changed since `Analysis Baseline`, do not touch the file and report that.

### Template
```markdown
# Requirements Analysis: <title> (<ID>)

- Source: <URL>
- Parent item: <ID> (or "None")
- Labels: <labels>
- Created: <YYYY-MM-DD>
- Last Updated: <YYYY-MM-DD>
- Analysis Baseline: <`createdAt` of the last reflected comment, or the issue `updatedAt` if there are no comments (ISO 8601)>

## Background and Problem
<Why this work is needed. Only what is confirmed in the issue body/comments>

## Goals
<The outcome this work aims for>

## Scope
### In Scope
- ...
### Out of Scope
- ...

## Functional Requirements
| ID | Requirement | Source |
|----|-------------|--------|
| FR-1 | ... | Body / Comment / Parent issue |

## Non-Functional Requirements
| ID | Requirement | Source |
|----|-------------|--------|
| NFR-1 | ... | ... |

## Acceptance Criteria
- [ ] <Verifiable completion condition>

## Impact
<Related modules, files, documents. Only what was confirmed from the code>

## Open Questions
- <Items not stated but needing a decision>

## Conflicts and Notes
<If the body and comments conflict, the final choice and why>

---

## Change History
| Date | Change | Source |
|------|--------|--------|
| <YYYY-MM-DD> | Initial draft | Body |
```

Omit a section only if it is truly not applicable; otherwise write "N/A".

## Step 4. Report
Summarize: the file path, the number of requirements, and the *Open Questions* that need the user's decision. Do not commit unless the user asks.

## Red Flags
- **Inventing requirements**: Only record what the sources state. Put inferences in *Open Questions*.
- **Ignoring comments**: Agreed details often exist only in comments. Always read them.
- **Designing the solution**: This document describes *what* is needed, not *how* to implement it.
- **Appending or overwriting an existing document**: Do not append new sections or regenerate from scratch. Edit in place, keep recorded decisions and IDs, and log the change in `Change History`.
