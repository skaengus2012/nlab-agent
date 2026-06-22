---
name: brainstorming
description: Use when exploring new ideas, features, or architectural options. Make sure to trigger this skill whenever the user asks to brainstorm, explore design options, generate feature ideas, or discuss architecture alternatives, even if they do not explicitly ask for 'brainstorming'.
---

# Brainstorming

## Purpose
Use this skill when you need to explore multiple solutions or define a new feature from scratch.

## Process
When navigating a brainstorming process interactively, guide the dialogue step-by-step using a single query per phase:
1. **Single Query Rule**: Ask only **one** focused question at a time to keep the session organized.
2. **Sequential Progress Tracking**: Keep track of the brainstorming phases in your inner monologue (e.g., `[Problem Definition: Done], [Divergence: Pending], [Convergence: Pending], [Selection: Pending]`) and only run the query corresponding to the active pending phase.
3. **Smart Skip**: If the user proactively defines the problem and proposes multiple ideas in their first reply, mark both phases as completed and proceed straight to the evaluation/convergence phase.
4. **Focused Prompting**: Keep each question concise and focused on the active phase. Do not ask the user to evaluate ideas while still in the divergence phase.
5. **Selection**: Summarize the best approach or a hybrid solution and link it to the next implementation plan.

## Guidelines
- Encourage wild ideas initially.
- Look for analogies in other domains (e.g., "How would Spotify solve this navigation problem?").
- Consider the User Experience (UX) first.
