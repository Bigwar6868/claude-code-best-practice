---
name: gitnexus-pr-review
description: "Use when the user wants to review a pull request, understand what a PR changes, assess risk of merging, or check for missing test coverage. Examples: 'Review this PR', 'What does PR #42 change?', 'Is this PR safe to merge?'"
user-invocable: true
---

# PR Review with GitNexus

> Source: [abhigyanpatwari/GitNexus](https://github.com/abhigyanpatwari/GitNexus)

## When to Use

- "Review this PR"
- "What does PR #42 change?"
- "Is this safe to merge?"
- "What's the blast radius of this PR?"
- "Are there missing tests for this PR?"

## Workflow

1. **Get diff:** `gh pr diff <number>`
2. **Map changes:** `gitnexus_detect_changes({scope: "compare", base_ref: "main"})`
3. **Analyze impact:** `gitnexus_impact({target: "<symbol>", direction: "upstream"})`
4. **Understand context:** `gitnexus_context({name: "<key symbol>"})`
5. **Examine flows:** `gitnexus://repo/{name}/processes`
6. **Synthesize** findings with risk categorization

> If "Index is stale" appears, run `npx gitnexus analyze` first.

## Review Dimensions

| Dimension | GitNexus Support |
|-----------|-----------------|
| **Correctness** | Context reveals callers and compatibility |
| **Blast radius** | Impact shows dependent coverage levels |
| **Completeness** | Detect_changes identifies all affected flows |
| **Test coverage** | Impact with includeTests reveals test touchpoints |
| **Breaking changes** | Unmapped d=1 dependencies indicate risks |

## Risk Assessment

| Signal | Classification |
|--------|---------------|
| <3 symbols, 0-1 processes affected | LOW |
| 3-10 symbols, 2-5 processes affected | MEDIUM |
| >10 symbols or multiple processes | HIGH |
| Changes to auth, payments, data integrity | CRITICAL |
| d=1 callers outside PR diff | Breakage risk |

## Output Format

```
## PR Review: [title]

**Risk: LOW / MEDIUM / HIGH / CRITICAL**

### Changes Summary
- X symbols changed in Y files
- Z execution flows affected

### Findings
1. **[severity]** Finding description with evidence

### Missing Coverage
- Unmapped dependencies
- Untested flows

### Recommendation
APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
```
