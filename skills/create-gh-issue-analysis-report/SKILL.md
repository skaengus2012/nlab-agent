---
name: create-gh-issue-analysis-report
description: Use when you need to turn a GitHub issue into a requirements analysis report. Takes an issue number or URL, reads the issue body, comments, and parent issue via `gh`, and generates a requirements analysis document inside the project. Make sure to use this skill whenever the user asks to analyze a GitHub issue, organize an issue's requirements, or write a requirements document for an issue, even if they do not explicitly ask for 'create-gh-issue-analysis-report'.
---

# Create GitHub Issue Analysis Report

## Overview
Requirements are commonly tracked as GitHub issues. Issue bodies are often thin or empty, and agreed details may live only in comments. This skill collects every source of requirements for one GitHub issue and organizes them into a single report inside the repository.

**Input**: a GitHub issue number (e.g. `869`) or URL. If the user did not provide one, ask for it.

**Output**: `docs/spec/issue<number>/requirements.md` (one file per issue; create the directory if it does not exist).

**Language**: Write the document (including headings) in the language the user asks for; if they did not say, ask once. Code blocks, file paths, and commands stay in English. The template below uses English headings; translate them as needed.

## When to Use
- The user gives a GitHub issue and asks to analyze or organize its requirements.
- Before implementation, when the issue body alone is not enough to start.
- After new comments change the agreed requirements of an existing report.

## Step 1. Collect Sources
Use the repository of the current working directory. Prefer structured output; the plain `--comments` view can come back empty.

```bash
# 1. Body, comments, labels, and timestamps
gh issue view <number> --json number,title,body,labels,state,comments,url,createdAt,updatedAt

# 2. Parent issue reference (null when there is none)
gh api repos/{owner}/{repo}/issues/<number> --jq .parent_issue_url
```

### Parent issue
Read the parent issue when **any** of the following holds:
- The body is empty or too thin to derive requirements.
- The body references the parent for background, goals, or scope.
- Terms or decisions in the issue are not explained anywhere else.

```bash
gh issue view <parent-number> --json number,title,body,comments,url
```

Do not follow the parent chain further than one level unless the user asks.

## Step 2. Analyze
Separate what the sources **state** from what you **infer**.

1. **Merge sources**: When the body and a comment conflict, the later comment wins. Note the conflict in the report.
2. **Extract requirements**: Turn each stated need into one verifiable statement. Give each an ID (`FR-1`, `NFR-1`).
3. **Incremental update**: If the report already exists, only analyze what changed after its `Analysis Baseline` (new comments, edited body). See Step 3.
4. **Mark uncertainty**: Anything not explicitly stated but required to proceed goes into *Open Questions*; never present guesses as requirements. A requirement's `Source` must be text actually stated in the body, a comment, or the parent issue. Do not list requirements inferred from conventions or intent (e.g. "follow the existing format") in the requirement tables; put them in *Open Questions* instead.
5. **Check the codebase when needed**: Look at related modules only to clarify impact scope. Do not design the implementation here.

If critical ambiguities remain, ask the user before writing the report.

## Step 3. Write the Report
Create the report at the output path (create the directory if it does not exist).

### If the report already exists
The report always represents the **current state** of the requirements. Never append a new section after a `---` separator; edit in place.

1. Read the existing report and its `Analysis Baseline`.
2. Reflect only changes made after that point (new comments, edited body) by modifying the affected items directly.
3. Do not delete a dropped requirement or reuse its ID. Mark it as `~~FR-3~~ (Dropped: <reason>)`. New requirements take the next unused ID.
4. Remove resolved *Open Questions* from the section and record the resolution in `Change History`. Do not leave "resolved" items behind.
5. Re-check every status-dependent statement (e.g. "No conflicts, since there are no comments" in `Conflicts and Notes`) and rewrite it to match the current sources.
6. Update `Last Updated` and `Analysis Baseline`.
7. Add one row to `Change History` (date, what changed, source). Never rewrite past rows.
8. If nothing changed since `Analysis Baseline`, do not touch the file and report that.

### Template
```markdown
# Requirements Analysis: <issue title> (#<number>)

- Issue: <URL>
- Parent issue: #<parent> (or "None")
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

## Step 4. Report to the User
Summarize: the file path, the number of requirements, and the *Open Questions* that need the user's decision. Do not commit unless the user asks.

## Red Flags
- **Inventing requirements**: Only record what the sources state. Put inferences in *Open Questions*.
- **Ignoring comments**: Agreed details often exist only in comments. Always read them.
- **Designing the solution**: This report describes *what* is needed, not *how* to implement it.
- **Appending or overwriting an existing report**: Do not append new sections or regenerate from scratch. Edit in place, keep recorded decisions and IDs, and log the change in `Change History`.
