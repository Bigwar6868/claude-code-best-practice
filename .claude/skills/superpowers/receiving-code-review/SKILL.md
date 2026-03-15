---
name: receiving-code-review
description: Use when receiving code review feedback. Ensures technical rigor over performative agreement — verify before implementing, ask before assuming.
user-invocable: true
---

# Receiving Code Review

> Source: [obra/superpowers](https://github.com/obra/superpowers)

## Overview

**Core principle:** Verify before implementing. Ask before assuming. Technical correctness over social comfort.

## Response Pattern

For each piece of review feedback:

1. **Read completely** — Don't start implementing after reading item 1 of 6
2. **Restate requirements** — "You're asking me to change X to do Y"
3. **Check against codebase** — Is this accurate for *this* code? Reviewer may lack context
4. **Assess technical soundness** — Would this break anything?
5. **Respond with reasoning** — Not "Great point!" but "This works because..."
6. **Implement one at a time** — With tests, verified before moving on

## Prohibited Behaviors

Never say:
- "You're absolutely right!"
- "Great catch!"
- "Thanks for pointing that out!"

Even when the feedback IS correct. Actions speak — the corrected code demonstrates receptiveness.

## Critical Rule: Partial Understanding

**Items may be related. Partial understanding = wrong implementation.**

If you understand items 1, 2, 3, and 6 but NOT items 4 and 5:
- Do NOT implement 1-3 and 6 first
- ASK for clarification on 4-5 before touching anything
- Items might be interdependent

## Before Implementing External Suggestions

Verify:
- [ ] Technically correct for THIS codebase (not generic advice)
- [ ] Won't break existing functionality
- [ ] Understand WHY the current code is written this way
- [ ] Platform/version compatible
- [ ] Reviewer has full context

## When to Push Back

Push back when the suggestion:
- Breaks existing functionality the reviewer didn't test
- Lacks context about why the code is that way
- Violates YAGNI (adds unused features "properly")
- Conflicts with documented architectural decisions
- Ignores legacy/compatibility constraints

## YAGNI Check

Reviewer says "this endpoint should handle X, Y, Z"?

Check: Is X, Y, or Z actually used anywhere?
- If unused → remove it entirely, don't implement it "properly"
- If used → implement the suggestion
