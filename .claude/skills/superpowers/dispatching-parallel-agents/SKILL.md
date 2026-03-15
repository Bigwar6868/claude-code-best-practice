---
name: dispatching-parallel-agents
description: Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies. Dispatches specialized agents concurrently.
user-invocable: true
---

# Dispatching Parallel Agents

> Source: [obra/superpowers](https://github.com/obra/superpowers)

## Overview

Dispatch one agent per independent problem domain. Let them work concurrently.

## When to Use

- 3+ test failures with different root causes
- Multiple broken subsystems
- Independent features that don't share state
- Problems that can be understood independently

## When NOT to Use

- Related failures where fixing one resolves others
- Situations requiring comprehensive system understanding
- Exploratory debugging phases
- Shared state where agents would interfere

## Decision Tree

```
Are failures independent?
├── YES → Can each be understood without shared context?
│         ├── YES → Dispatch parallel agents
│         └── NO  → Handle sequentially
└── NO  → Fix root cause first, then assess remaining
```

## Process

### 1. Group by Component

Organize failures by broken component/subsystem:
```
Component A: [failure 1, failure 4]
Component B: [failure 2, failure 5]
Component C: [failure 3, failure 6]
```

### 2. Craft Focused Prompts

Each agent prompt must include:
- **Specific scope** — Exact files, functions, test names
- **Clear goal** — What "fixed" looks like
- **Expected output** — What to deliver back
- **Context** — Relevant error messages, stack traces

### 3. Launch Concurrently

```
Agent(description="Fix Component A failures", prompt="...", model="sonnet")
Agent(description="Fix Component B failures", prompt="...", model="sonnet")
Agent(description="Fix Component C failures", prompt="...", model="sonnet")
```

### 4. Review and Integrate

- Review each agent's summary
- Verify changes don't conflict
- Run integrated test suite
- Address any cross-cutting issues

## Anti-Patterns

| Pattern | Problem |
|---------|---------|
| Vague prompts | "Fix the tests" — too broad, agent wastes time |
| Overlapping scope | Two agents editing same file — merge conflicts |
| Missing context | Agent can't reproduce without error details |
| No verification | Trusting agent output without running tests |
