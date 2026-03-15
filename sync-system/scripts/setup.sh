#!/bin/bash
# ============================================================================
# setup.sh — Bootstrap Claude Code config sync on a new machine
# ============================================================================
# Usage: ./sync-system/scripts/setup.sh [--github-user USERNAME]
#
# What it does:
#   1. Creates ~/.claude-config/ backup directory
#   2. Links sync/restore/discover scripts
#   3. Adds shell aliases (cc, ccs, ccr, ccd, ccm)
#   4. Optionally connects to GitHub for remote backup
# ============================================================================
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }

# Parse args
GITHUB_USER=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --github-user) GITHUB_USER="$2"; shift 2 ;;
        *) echo "Usage: $0 [--github-user USERNAME]"; exit 1 ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.claude-config"
CLAUDE_DIR="$HOME/.claude"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Claude Code Sync System — Setup         ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Step 1: Create config directory
info "Creating $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"/{backups,mcp-servers,plugins,scripts}

if [ ! -d "$CONFIG_DIR/.git" ]; then
    cd "$CONFIG_DIR"
    git init -b main
    log "Initialized git repo at $CONFIG_DIR"
else
    log "Git repo already exists at $CONFIG_DIR"
fi

# Step 2: Copy scripts
info "Installing scripts..."
cp "$SCRIPT_DIR/sync.sh"        "$CONFIG_DIR/scripts/sync.sh"
cp "$SCRIPT_DIR/restore.sh"     "$CONFIG_DIR/scripts/restore.sh"
cp "$SCRIPT_DIR/discover.sh"    "$CONFIG_DIR/scripts/discover.sh"
cp "$SCRIPT_DIR/health-check.sh" "$CONFIG_DIR/scripts/health-check.sh"
chmod +x "$CONFIG_DIR/scripts/"*.sh
log "Scripts installed to $CONFIG_DIR/scripts/"

# Step 3: Take initial snapshot
info "Taking initial config snapshot..."
mkdir -p "$CLAUDE_DIR"

[ -f "$CLAUDE_DIR/CLAUDE.md" ]    && cp "$CLAUDE_DIR/CLAUDE.md" "$CONFIG_DIR/" && log "Backed up CLAUDE.md"
[ -f "$CLAUDE_DIR/settings.json" ] && cp "$CLAUDE_DIR/settings.json" "$CONFIG_DIR/" && log "Backed up settings.json"
[ -f "$HOME/.claude.json" ]        && cp "$HOME/.claude.json" "$CONFIG_DIR/claude-mcp.json" && log "Backed up MCP config"

# Step 4: Shell aliases
info "Setting up shell aliases..."
SHELL_RC="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"

if ! grep -q "# Claude Code Sync" "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" << 'ALIASES'

# Claude Code Sync — aliases
alias cc="claude"
alias ccs="~/.claude-config/scripts/sync.sh"
alias ccr="~/.claude-config/scripts/restore.sh"
alias ccd="~/.claude-config/scripts/discover.sh"
alias ccm="claude mcp list"
alias cch="~/.claude-config/scripts/health-check.sh"
ALIASES
    log "Aliases added to $SHELL_RC"
else
    log "Aliases already present in $SHELL_RC"
fi

# Step 5: GitHub remote (optional)
if [ -n "$GITHUB_USER" ]; then
    info "Connecting to GitHub..."
    REMOTE_URL="https://github.com/$GITHUB_USER/claude-code-config.git"

    cd "$CONFIG_DIR"
    if ! git remote get-url origin &>/dev/null; then
        git remote add origin "$REMOTE_URL"
        log "Remote set to $REMOTE_URL"
    else
        log "Remote already configured: $(git remote get-url origin)"
    fi

    # Check if repo exists
    if command -v gh &>/dev/null; then
        if ! gh repo view "$GITHUB_USER/claude-code-config" &>/dev/null; then
            warn "Repo doesn't exist yet. Creating..."
            gh repo create "$GITHUB_USER/claude-code-config" --private --source=. --push && log "Created and pushed!" || warn "Create manually: gh repo create $GITHUB_USER/claude-code-config --private"
        else
            log "Repo exists at $REMOTE_URL"
        fi
    else
        warn "gh CLI not installed — create repo manually:"
        echo "  gh repo create $GITHUB_USER/claude-code-config --private"
    fi
fi

# Step 6: Initial commit
cd "$CONFIG_DIR"
git add -A 2>/dev/null
if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "feat: initial claude code config snapshot" 2>/dev/null && log "Initial commit created" || warn "Commit failed (may need git config)"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Setup Complete!                         ║"
echo "╠══════════════════════════════════════════╣"
echo "║                                          ║"
echo "║  Aliases (source $SHELL_RC first):       ║"
echo "║    cc  → claude                          ║"
echo "║    ccs → sync config to GitHub           ║"
echo "║    ccr → restore config from GitHub      ║"
echo "║    ccd → discover new plugins/MCP        ║"
echo "║    ccm → list MCP servers                ║"
echo "║    cch → health check                    ║"
echo "║                                          ║"
echo "╚══════════════════════════════════════════╝"
echo ""
[ -n "$GITHUB_USER" ] || warn "Run with --github-user USERNAME to enable remote backup"
