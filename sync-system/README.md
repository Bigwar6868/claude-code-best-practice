# Claude Code Sync System

Backup, restore, and discover Claude Code configurations across devices.

## Quick Start

```bash
# 1. Bootstrap on a new machine
./sync-system/scripts/setup.sh --github-user Bigwar6868

# 2. Source your shell to activate aliases
source ~/.bashrc  # or ~/.zshrc
```

## Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `cc`  | `claude` | Launch Claude Code |
| `ccs` | `sync.sh` | Backup configs to git |
| `ccr` | `restore.sh` | Restore configs on new machine |
| `ccd` | `discover.sh` | Discover skills, plugins, MCP servers |
| `ccm` | `claude mcp list` | List MCP servers |
| `cch` | `health-check.sh` | Run diagnostic checks |

## Scripts

### `setup.sh` — Bootstrap

Creates `~/.claude-config/`, copies scripts, adds shell aliases, and optionally connects to a GitHub repo for remote backup.

```bash
./sync-system/scripts/setup.sh                        # Local only
./sync-system/scripts/setup.sh --github-user USERNAME  # With GitHub
```

### `sync.sh` — Backup

Copies current configs into `~/.claude-config/`, creates a timestamped backup, commits to git, and pushes to remote if configured.

**What gets synced:**
- `~/.claude/CLAUDE.md` — Global instructions
- `~/.claude/settings.json` — Global settings (permissions, hooks)
- `~/.claude.json` — MCP server configurations
- `.claude/` project configs (skills, commands, settings) — if run from a project directory

### `restore.sh` — Restore

Pulls latest from remote (if configured), creates a safety backup of current configs, then restores from `~/.claude-config/`.

### `discover.sh` — Discovery

Scans and reports on your Claude Code setup: global config status, MCP servers, project skills/commands/agents, enabled plugins, and registered marketplaces.

### `health-check.sh` — Diagnostics

Validates your setup with pass/warn/fail checks: installation (claude, node, git, jq), JSON syntax validation, sync status, disk usage, and CLAUDE.md line count.

## Directory Structure

```
~/.claude-config/
├── .git/                  # Version control
├── backups/               # Timestamped snapshots
│   ├── 2026-03-15_14-30/
│   └── pre-restore-*/     # Safety backups before restore
├── projects/              # Per-project config backups
│   └── <project-name>/
├── scripts/               # Installed scripts
├── CLAUDE.md              # Latest global instructions
├── settings.json          # Latest global settings
├── claude-mcp.json        # Latest MCP config
└── manifest.json          # Sync metadata
```

## Three Sync Layers

Claude Code configs exist at three levels, each requiring different sync strategies:

1. **Project-level** (`.claude/settings.json`, skills, commands) — synced via git with the project
2. **User-level** (`~/.claude/CLAUDE.md`, `~/.claude/settings.json`) — synced via this system
3. **MCP servers** (`~/.claude.json`) — synced via this system

The `enabledPlugins` and `extraKnownMarketplaces` fields in project `.claude/settings.json` handle cross-device plugin availability automatically through git.

## Remote Setup

If you didn't set up GitHub during `setup.sh`:

```bash
cd ~/.claude-config
git remote add origin https://github.com/USERNAME/claude-code-config.git
gh repo create USERNAME/claude-code-config --private --source=. --push
```
