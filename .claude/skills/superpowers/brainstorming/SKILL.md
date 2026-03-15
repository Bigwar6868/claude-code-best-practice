---
name: brainstorming
description: Use BEFORE any creative work — creating features, building components, adding functionality, or modifying behavior. Explores intent, requirements, and design before implementation.
user-invocable: true
---

# Brainstorming Ideas Into Designs

> Source: [obra/superpowers](https://github.com/obra/superpowers)

## Overview

Transform ideas into fully-formed designs through collaborative dialogue BEFORE any implementation.

**Critical gate:** Do NOT write any code, scaffold any project, or take any implementation action until a design is presented and approved.

## Process

### 1. Explore Context
Review existing files, docs, and patterns in the codebase.

### 2. Ask Clarifying Questions
- One question per message (don't overwhelm)
- Prefer multiple-choice when feasible
- Understand purpose, constraints, and non-goals

### 3. Propose 2-3 Approaches
For each approach:
- Brief description
- Trade-offs (pros/cons)
- Recommendation with reasoning

### 4. Present Design
- Break into appropriately-scaled sections
- Seek approval after each section
- For large projects, break into smaller sub-projects

### 5. Write Design Doc
Save to `docs/specs/YYYY-MM-DD-<topic>-design.md`

### 6. Review & Approve
- User reviews written spec
- Iterate until approved
- Only then transition to implementation

## Design Principles

- **Isolation** — Clear unit boundaries, well-defined interfaces
- **Existing patterns** — Follow what's already in the codebase
- **Scope control** — Break large projects into independently-scoped sub-projects
- **No premature implementation** — Design phase produces documents, not code

## Transition

After design approval, invoke `writing-plans` skill to create the implementation plan.

```
brainstorming → writing-plans → implementation
     (why)          (how)          (do)
```
