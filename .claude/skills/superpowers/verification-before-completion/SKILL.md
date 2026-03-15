---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing — requires running verification commands and confirming output before making any success claims. Evidence before assertions always.
user-invocable: true
---

# Verification Before Completion

> Source: [obra/superpowers](https://github.com/obra/superpowers)

## Overview

Claiming completion without running fresh verification is dishonest.

**Core principle:** Evidence before claims, always.

## The Gate

Before ANY claim of completion, run this gate:

1. **Identify** — What command proves the claim?
2. **Execute** — Run it completely
3. **Read** — Full output and exit code
4. **Verify** — Output confirms the assertion
5. **Claim** — Only then make the claim

## Applies To

- "Tests pass" → Show test output with 0 failures
- "Build succeeds" → Show clean build output
- "Bug is fixed" → Show reproduction attempt failing (bug gone)
- "Feature works" → Show feature in action
- "PR is ready" → Show all checks passing

## Red Flags

If you catch yourself:
- Using "should" or "probably" about outcomes
- Expressing satisfaction before running verification
- Relying on partial checks
- Trusting agent reports without independent verification
- Saying "I believe this works" without evidence

**STOP.** Run the verification command.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I'm confident it works" | Confidence is not evidence |
| "I'm tired, I'll verify later" | Unverified claims are false claims |
| "Just this once" | No exceptions |
| "The agent said it passed" | Verify independently |
| "I manually tested it" | Show the output |

## Checklist

- [ ] Identified verification command
- [ ] Ran it to completion
- [ ] Read full output (not just exit code)
- [ ] Output confirms claim
- [ ] No warnings or errors in output
- [ ] Documented evidence in response
