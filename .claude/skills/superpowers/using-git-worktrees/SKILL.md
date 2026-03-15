---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans. Creates isolated git worktrees with smart directory selection and safety verification.
user-invocable: true
---

# Using Git Worktrees

> Source: [obra/superpowers](https://github.com/obra/superpowers)

## Overview

Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching.

**Core principle:** Systematic directory selection + safety verification = reliable isolation.

## Directory Selection (Priority Order)

1. **Check existing:** `ls -d .worktrees worktrees 2>/dev/null` — use what exists (`.worktrees` wins if both)
2. **Check CLAUDE.md:** `grep -i "worktree.*director" CLAUDE.md` — use if specified
3. **Ask user** — offer `.worktrees/` (project-local, hidden) or `~/.config/superpowers/worktrees/<project>/` (global)

## Safety Verification

For project-local directories, **MUST verify ignored before creating:**

```bash
git check-ignore -q .worktrees 2>/dev/null
```

If NOT ignored: add to `.gitignore`, commit, then proceed.

## Creation Steps

```bash
# 1. Detect project name
project=$(basename "$(git rev-parse --show-toplevel)")

# 2. Create worktree
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"

# 3. Auto-detect and run setup
[ -f package.json ] && npm install
[ -f Cargo.toml ] && cargo build
[ -f requirements.txt ] && pip install -r requirements.txt
[ -f go.mod ] && go mod download

# 4. Verify clean baseline
npm test  # or cargo test, pytest, go test ./...
```

## Quick Reference

| Situation | Action |
|-----------|--------|
| `.worktrees/` exists | Use it (verify ignored) |
| `worktrees/` exists | Use it (verify ignored) |
| Both exist | Use `.worktrees/` |
| Neither exists | Check CLAUDE.md → Ask user |
| Directory not ignored | Add to .gitignore + commit |
| Tests fail during baseline | Report failures + ask |

## Red Flags

- Never create worktree without verifying it's ignored (project-local)
- Never skip baseline test verification
- Never proceed with failing tests without asking
- Never assume directory location when ambiguous
