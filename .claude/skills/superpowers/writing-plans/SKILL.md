---
name: writing-plans
description: Use before implementing any feature or multi-step task. Creates comprehensive, bite-sized implementation plans with test-first workflow. Assumes the engineer has zero context.
user-invocable: true
---

# Writing Plans

> Source: [obra/superpowers](https://github.com/obra/superpowers)

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for the codebase.

**Core principle:** Plans should be so detailed that someone unfamiliar with the project can execute them.

## When to Use

- Before any feature implementation
- Before multi-step refactoring
- Before any task requiring 3+ files changed
- When someone asks "how should we build X?"

## Plan Structure

### Header (required)

```markdown
# Feature: <name>
**Goal:** One-sentence description
**Architecture:** 2-3 sentences on approach
**Tech stack:** Languages, frameworks, tools
```

### File Map

List every file that will be created or modified:

```markdown
## Files
- CREATE: `src/auth/validator.ts` — Email validation
- MODIFY: `src/auth/login.ts` — Add validation call
- CREATE: `src/auth/__tests__/validator.test.ts` — Tests
```

### Task Decomposition

Each task must:
- Take 2-5 minutes to complete
- Follow test-first workflow (RED → GREEN → REFACTOR)
- Include exact file paths
- Include complete code snippets
- Include CLI commands with expected outputs
- Use checkbox syntax for tracking

```markdown
### Task 1: Add email validation

- [ ] **Test (RED):** Create `src/auth/__tests__/validator.test.ts`
  ```typescript
  // exact test code here
  ```
  Run: `npm test -- validator` → Expected: 1 failing

- [ ] **Implement (GREEN):** Create `src/auth/validator.ts`
  ```typescript
  // exact implementation code here
  ```
  Run: `npm test -- validator` → Expected: 1 passing

- [ ] **Commit:** `git commit -m "feat: add email validation"`
```

## Key Rules

1. **TDD always** — Write failing test, then minimal implementation
2. **One commit per task** — Frequent, atomic commits
3. **DRY/YAGNI** — Don't build what isn't needed
4. **Exact specifications** — No vague "add appropriate error handling"
5. **Expected outputs** — Every command shows what success looks like

## Quality Check

After each logical chunk (~1000 lines of plan):
- Review for completeness — can someone execute this blind?
- Review for correctness — do the code snippets actually work?
- Review for order — do tasks build on each other correctly?

## Output

Save plan to: `docs/plans/YYYY-MM-DD-<feature-name>.md`

Then transition to implementation via executing-plans or subagent-driven-development.
