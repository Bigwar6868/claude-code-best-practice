#!/bin/bash
# ============================================================================
# restore.sh — Restore Claude Code configs on a new machine
# ============================================================================
# Usage: ccr  (or ~/.claude-config/scripts/restore.sh)
#
# Restores:
#   - CLAUDE.md         → ~/.claude/CLAUDE.md
#   - settings.json     → ~/.claude/settings.json
#   - claude-mcp.json   → ~/.claude.json
#   - Optionally pulls from remote first
# ============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }

CONFIG_DIR="$HOME/.claude-config"
CLAUDE_DIR="$HOME/.claude"

if [ ! -d "$CONFIG_DIR" ]; then
    err "Config directory not found at $CONFIG_DIR"
    err "Run setup.sh first, or clone your config repo:"
    echo "  git clone https://github.com/<user>/claude-code-config.git $CONFIG_DIR"
    exit 1
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Claude Code Sync — Restore              ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Step 1: Pull from remote (if available)
if [ -d "$CONFIG_DIR/.git" ]; then
    cd "$CONFIG_DIR"
    if git remote get-url origin &>/dev/null; then
        info "Pulling latest from remote..."
        if git pull origin main 2>/dev/null; then
            log "Pulled latest changes"
        else
            warn "Pull failed — using local copy"
        fi
    fi
fi

# Step 2: Show what will be restored
info "Files available for restore:"
[ -f "$CONFIG_DIR/CLAUDE.md" ]       && echo "  - CLAUDE.md (global instructions)"
[ -f "$CONFIG_DIR/settings.json" ]   && echo "  - settings.json (global settings)"
[ -f "$CONFIG_DIR/claude-mcp.json" ] && echo "  - claude-mcp.json (MCP servers)"

echo ""

# Step 3: Backup current configs before overwriting
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
SAFETY_DIR="$CONFIG_DIR/backups/pre-restore-$TIMESTAMP"
mkdir -p "$SAFETY_DIR"

if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    cp "$CLAUDE_DIR/CLAUDE.md" "$SAFETY_DIR/CLAUDE.md"
    info "Backed up current CLAUDE.md"
fi
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$CLAUDE_DIR/settings.json" "$SAFETY_DIR/settings.json"
    info "Backed up current settings.json"
fi
if [ -f "$HOME/.claude.json" ]; then
    cp "$HOME/.claude.json" "$SAFETY_DIR/claude-mcp.json"
    info "Backed up current MCP config"
fi

# Step 4: Restore configs
info "Restoring configs..."
mkdir -p "$CLAUDE_DIR"

if [ -f "$CONFIG_DIR/CLAUDE.md" ]; then
    cp "$CONFIG_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    log "Restored CLAUDE.md → ~/.claude/CLAUDE.md"
fi

if [ -f "$CONFIG_DIR/settings.json" ]; then
    cp "$CONFIG_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    log "Restored settings.json → ~/.claude/settings.json"
fi

if [ -f "$CONFIG_DIR/claude-mcp.json" ]; then
    cp "$CONFIG_DIR/claude-mcp.json" "$HOME/.claude.json"
    log "Restored MCP config → ~/.claude.json"
fi

# Step 5: Show manifest info
if [ -f "$CONFIG_DIR/manifest.json" ]; then
    echo ""
    info "Last sync info:"
    if command -v jq &>/dev/null; then
        LAST_SYNC=$(jq -r '.last_sync // "unknown"' "$CONFIG_DIR/manifest.json")
        LAST_HOST=$(jq -r '.hostname // "unknown"' "$CONFIG_DIR/manifest.json")
        echo "  Synced: $LAST_SYNC"
        echo "  From:   $LAST_HOST"
    else
        cat "$CONFIG_DIR/manifest.json"
    fi
fi

echo ""
log "Restore complete!"
info "Safety backup saved to: $SAFETY_DIR"
echo ""
warn "Restart Claude Code for changes to take effect."
echo ""
