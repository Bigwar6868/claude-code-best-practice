#!/bin/bash
# ============================================================================
# discover.sh — Discover new Claude Code plugins, skills, and MCP servers
# ============================================================================
# Usage: ccd  (or ~/.claude-config/scripts/discover.sh)
#
# Checks:
#   - Installed plugins vs available in known marketplaces
#   - MCP server status
#   - Skill directories across projects
#   - New community resources
# ============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }
header() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}"; }

CLAUDE_DIR="$HOME/.claude"
MCP_CONFIG="$HOME/.claude.json"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Claude Code — Discovery                 ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Section 1: Global Config Status ──
header "Global Configuration"

if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    LINES=$(wc -l < "$CLAUDE_DIR/CLAUDE.md")
    log "CLAUDE.md found ($LINES lines)"
else
    warn "No global CLAUDE.md — create one at ~/.claude/CLAUDE.md"
fi

if [ -f "$CLAUDE_DIR/settings.json" ]; then
    log "Global settings.json found"
    if command -v jq &>/dev/null; then
        PERMS=$(jq '.permissions.allow | length' "$CLAUDE_DIR/settings.json" 2>/dev/null || echo "?")
        echo "    Allowed permissions: $PERMS"
    fi
else
    warn "No global settings.json"
fi

# ── Section 2: MCP Servers ──
header "MCP Servers"

if [ -f "$MCP_CONFIG" ]; then
    if command -v jq &>/dev/null; then
        SERVERS=$(jq -r '.mcpServers // {} | keys[]' "$MCP_CONFIG" 2>/dev/null)
        if [ -n "$SERVERS" ]; then
            COUNT=$(echo "$SERVERS" | wc -l)
            log "$COUNT MCP server(s) configured:"
            echo "$SERVERS" | while read -r server; do
                TRANSPORT=$(jq -r ".mcpServers.\"$server\".type // .mcpServers.\"$server\".command // \"unknown\"" "$MCP_CONFIG" 2>/dev/null)
                echo "    - $server ($TRANSPORT)"
            done
        else
            warn "No MCP servers configured"
        fi
    else
        log "MCP config exists at $MCP_CONFIG (install jq for details)"
    fi
else
    warn "No MCP config found at $MCP_CONFIG"
    info "Add servers with: claude mcp add <name> --transport stdio <command>"
fi

# ── Section 3: Project Skills ──
header "Skills (Current Project)"

if [ -d ".claude/skills" ]; then
    SKILL_COUNT=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l)
    log "$SKILL_COUNT skill(s) found:"
    find .claude/skills -name "SKILL.md" 2>/dev/null | while read -r skill; do
        SKILL_DIR=$(dirname "$skill")
        SKILL_NAME=$(basename "$SKILL_DIR")
        DESC=$(grep -m1 "^description:" "$skill" 2>/dev/null | sed 's/^description: *//' || echo "no description")
        echo "    - $SKILL_NAME: $DESC"
    done
else
    info "No .claude/skills/ in current project"
fi

# ── Section 4: Project Commands ──
header "Commands (Current Project)"

if [ -d ".claude/commands" ]; then
    CMD_COUNT=$(find .claude/commands -name "*.md" 2>/dev/null | wc -l)
    log "$CMD_COUNT command(s) found:"
    find .claude/commands -name "*.md" 2>/dev/null | while read -r cmd; do
        CMD_NAME=$(basename "$cmd" .md)
        echo "    - /$CMD_NAME"
    done
else
    info "No .claude/commands/ in current project"
fi

# ── Section 5: Project Agents ──
header "Agents (Current Project)"

if [ -d ".claude/agents" ]; then
    AGENT_COUNT=$(find .claude/agents -name "*.md" 2>/dev/null | wc -l)
    log "$AGENT_COUNT agent(s) found:"
    find .claude/agents -name "*.md" 2>/dev/null | while read -r agent; do
        AGENT_NAME=$(basename "$agent" .md)
        echo "    - $AGENT_NAME"
    done
else
    info "No .claude/agents/ in current project"
fi

# ── Section 6: Plugins (from project settings) ──
header "Enabled Plugins"

if [ -f ".claude/settings.json" ]; then
    if command -v jq &>/dev/null; then
        PLUGINS=$(jq -r '.enabledPlugins // {} | keys[]' ".claude/settings.json" 2>/dev/null)
        if [ -n "$PLUGINS" ]; then
            PLUGIN_COUNT=$(echo "$PLUGINS" | wc -l)
            log "$PLUGIN_COUNT plugin(s) enabled:"
            echo "$PLUGINS" | while read -r plugin; do
                echo "    - $plugin"
            done
        else
            info "No plugins enabled in project settings"
        fi

        # Marketplaces
        MARKETS=$(jq -r '.extraKnownMarketplaces // {} | keys[]' ".claude/settings.json" 2>/dev/null)
        if [ -n "$MARKETS" ]; then
            echo ""
            MARKET_COUNT=$(echo "$MARKETS" | wc -l)
            log "$MARKET_COUNT marketplace(s) registered:"
            echo "$MARKETS" | while read -r market; do
                REPO=$(jq -r ".extraKnownMarketplaces.\"$market\".source.repo // \"unknown\"" ".claude/settings.json" 2>/dev/null)
                echo "    - $market → github.com/$REPO"
            done
        fi
    fi
else
    info "No project .claude/settings.json"
fi

# ── Section 7: Suggestions ──
header "Suggestions"

# Check for common missing tools
if ! command -v jq &>/dev/null; then
    warn "Install jq for better config inspection: sudo apt install jq"
fi

if ! command -v gh &>/dev/null; then
    warn "Install GitHub CLI for remote sync: https://cli.github.com"
fi

if [ ! -f "$HOME/.claude-config/.git/config" ]; then
    warn "Sync system not set up — run: ./sync-system/scripts/setup.sh"
fi

echo ""
log "Discovery complete!"
echo ""
