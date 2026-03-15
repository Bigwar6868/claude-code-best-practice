---
name: gitnexus-exploring
description: "Use when the user asks how code works, wants to understand architecture, trace execution flows, or explore unfamiliar parts of the codebase. Examples: 'How does X work?', 'What calls this function?', 'Show me the auth flow'"
user-invocable: true
---

# Codebase Exploration with GitNexus

> Source: [abhigyanpatwari/GitNexus](https://github.com/abhigyanpatwari/GitNexus)

## When to Use

- "How does X work?"
- "What calls this function?"
- "Show me the auth flow"
- "What's the architecture of this module?"
- Understanding unfamiliar code areas

## Workflow

1. **Discover repos:** `gitnexus://repos`
2. **Review overview:** Check codebase overview and staleness status
3. **Query flows:** `gitnexus_query` to locate execution flows related to concepts
4. **Examine symbols:** `gitnexus_context` for bidirectional caller/callee relationships
5. **Trace paths:** Follow complete execution traces
6. **Review source:** Read actual implementations

> If "Index is stale" appears, run `npx gitnexus analyze` first.

## Available Resources

| Resource | Token Cost | Content |
|----------|-----------|---------|
| Repository context | ~150 | Overview and structure |
| Functional area clusters | ~300 | Cohesion metrics |
| Cluster membership | ~500 | Detailed groupings |
| Execution traces | ~200 | Step-by-step flows |

## Key Tools

- **`gitnexus_query`** — Locates execution flows related to specific concepts
- **`gitnexus_context`** — Provides bidirectional caller/callee relationships and process involvement
- **`gitnexus_impact`** — Shows blast radius of changes
- **`gitnexus_detect_changes`** — Maps code changes to execution flows
