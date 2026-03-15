#!/bin/bash
# ============================================================================
# sync.sh — Backup Claude Code configs to Git (local + optional remote)
# ============================================================================
# Usage: ccs  (or ~/.claude-config/scripts/sync.sh)
#
# Backs up:
#   - ~/.claude/CLAUDE.md         → global instructions
#   - ~/.claude/settings.json     → global settings
#   - ~/.claude.json              → MCP server configs
#   - Project .claude/ configs    → if run from a project with .claude/
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
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

if [ ! -d "$CONFIG_DIR/.git" ]; then
    err "Config directory not initialized. Run setup.sh first."
    exit 1
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Claude Code Sync — Backup               ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Step 1: Create timestamped backup
info "Creating backup snapshot ($TIMESTAMP)..."
BACKUP_DIR="$CONFIG_DIR/backups/$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

# Step 2: Sync global configs
info "Syncing global configs..."

if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    cp "$CLAUDE_DIR/CLAUDE.md" "$CONFIG_DIR/CLAUDE.md"
    cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/CLAUDE.md"
    log "CLAUDE.md synced"
else
    warn "No ~/.claude/CLAUDE.md found"
fi

if [ -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$CLAUDE_DIR/settings.json" "$CONFIG_DIR/settings.json"
    cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/settings.json"
    log "settings.json synced"
else
    warn "No ~/.claude/settings.json found"
fi

if [ -f "$HOME/.claude.json" ]; then
    cp "$HOME/.claude.json" "$CONFIG_DIR/claude-mcp.json"
    cp "$HOME/.claude.json" "$BACKUP_DIR/claude-mcp.json"
    log "MCP config synced"
else
    warn "No ~/.claude.json found"
fi

# Step 3: Sync project configs (if in a project with .claude/)
if [ -d ".claude" ] && [ "$(pwd)" != "$HOME" ]; then
    PROJECT_NAME=$(basename "$(pwd)")
    PROJECT_BACKUP="$CONFIG_DIR/projects/$PROJECT_NAME"
    mkdir -p "$PROJECT_BACKUP"

    if [ -f ".claude/settings.json" ]; then
        cp ".claude/settings.json" "$PROJECT_BACKUP/settings.json"
        log "Project settings synced ($PROJECT_NAME)"
    fi

    if [ -d ".claude/skills" ]; then
        rsync -a --delete ".claude/skills/" "$PROJECT_BACKUP/skills/" 2>/dev/null \
            || cp -r ".claude/skills/" "$PROJECT_BACKUP/skills/"
        log "Project skills synced ($PROJECT_NAME)"
    fi

    if [ -d ".claude/commands" ]; then
        rsync -a --delete ".claude/commands/" "$PROJECT_BACKUP/commands/" 2>/dev/null \
            || cp -r ".claude/commands/" "$PROJECT_BACKUP/commands/"
        log "Project commands synced ($PROJECT_NAME)"
    fi
fi

# Step 4: Generate manifest
info "Generating manifest..."
cat > "$CONFIG_DIR/manifest.json" << EOF
{
  "last_sync": "$TIMESTAMP",
  "hostname": "$(hostname 2>/dev/null || echo 'unknown')",
  "user": "$(whoami 2>/dev/null || echo 'unknown')",
  "files": {
    "CLAUDE.md": $([ -f "$CONFIG_DIR/CLAUDE.md" ] && echo "true" || echo "false"),
    "settings.json": $([ -f "$CONFIG_DIR/settings.json" ] && echo "true" || echo "false"),
    "claude-mcp.json": $([ -f "$CONFIG_DIR/claude-mcp.json" ] && echo "true" || echo "false")
  }
}
EOF
log "Manifest updated"

# Step 5: Commit to local git
info "Committing changes..."
cd "$CONFIG_DIR"
git add -A 2>/dev/null

if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "sync: backup $TIMESTAMP" 2>/dev/null && log "Changes committed" || warn "Commit failed"
else
    log "No changes to commit (already up to date)"
fi

# Step 6: Push to remote (if configured)
if git remote get-url origin &>/dev/null; then
    info "Pushing to remote..."
    if git push origin main 2>/dev/null; then
        log "Pushed to remote"
    else
        warn "Push failed — run 'cd $CONFIG_DIR && git push origin main' manually"
    fi
else
    info "No remote configured. Add one with: cd $CONFIG_DIR && git remote add origin <url>"
fi

# Cleanup old backups (keep last 10)
BACKUP_COUNT=$(ls -d "$CONFIG_DIR/backups/"*/ 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 10 ]; then
    ls -dt "$CONFIG_DIR/backups/"*/ | tail -n +11 | xargs rm -rf
    log "Cleaned old backups (kept last 10)"
fi

echo ""
log "Sync complete!"
echo ""
