#!/bin/bash
# ============================================================================
# health-check.sh — Diagnose Claude Code configuration issues
# ============================================================================
# Usage: cch  (or ~/.claude-config/scripts/health-check.sh)
#
# Checks:
#   - Claude Code installation
#   - Config file validity (JSON syntax)
#   - MCP server connectivity
#   - Git sync status
#   - Disk usage of config directories
# ============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
WARN=0
FAIL=0

pass() { echo -e "  ${GREEN}PASS${NC}  $1"; ((PASS++)); }
warning() { echo -e "  ${YELLOW}WARN${NC}  $1"; ((WARN++)); }
fail() { echo -e "  ${RED}FAIL${NC}  $1"; ((FAIL++)); }
header() { echo -e "\n${CYAN}── $1 ──${NC}"; }

CLAUDE_DIR="$HOME/.claude"
CONFIG_DIR="$HOME/.claude-config"
MCP_CONFIG="$HOME/.claude.json"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Claude Code — Health Check              ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Claude Code Installation ──
header "Installation"

if command -v claude &>/dev/null; then
    VERSION=$(claude --version 2>/dev/null || echo "unknown")
    pass "Claude Code installed ($VERSION)"
else
    fail "Claude Code not found in PATH"
fi

if command -v node &>/dev/null; then
    NODE_VER=$(node --version 2>/dev/null)
    pass "Node.js installed ($NODE_VER)"
else
    fail "Node.js not found (required for Claude Code)"
fi

if command -v git &>/dev/null; then
    pass "Git installed"
else
    fail "Git not found"
fi

if command -v jq &>/dev/null; then
    pass "jq installed (config inspection)"
else
    warning "jq not installed (optional but recommended)"
fi

# ── Config Files ──
header "Configuration Files"

# Global CLAUDE.md
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    LINES=$(wc -l < "$CLAUDE_DIR/CLAUDE.md")
    if [ "$LINES" -gt 200 ]; then
        warning "CLAUDE.md is $LINES lines (recommended: <200 for reliable adherence)"
    else
        pass "CLAUDE.md ($LINES lines)"
    fi
else
    warning "No global CLAUDE.md at $CLAUDE_DIR/CLAUDE.md"
fi

# Global settings.json
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    if command -v jq &>/dev/null; then
        if jq empty "$CLAUDE_DIR/settings.json" 2>/dev/null; then
            pass "Global settings.json (valid JSON)"
        else
            fail "Global settings.json has invalid JSON syntax"
        fi
    else
        pass "Global settings.json exists"
    fi
else
    warning "No global settings.json"
fi

# MCP config
if [ -f "$MCP_CONFIG" ]; then
    if command -v jq &>/dev/null; then
        if jq empty "$MCP_CONFIG" 2>/dev/null; then
            SERVER_COUNT=$(jq '.mcpServers // {} | length' "$MCP_CONFIG" 2>/dev/null || echo 0)
            pass "MCP config valid ($SERVER_COUNT server(s))"
        else
            fail "MCP config ($MCP_CONFIG) has invalid JSON syntax"
        fi
    else
        pass "MCP config exists"
    fi
else
    warning "No MCP config at $MCP_CONFIG"
fi

# ── Project Config ──
header "Project Configuration"

if [ -f ".claude/settings.json" ]; then
    if command -v jq &>/dev/null; then
        if jq empty ".claude/settings.json" 2>/dev/null; then
            PLUGIN_COUNT=$(jq '.enabledPlugins // {} | length' ".claude/settings.json" 2>/dev/null || echo 0)
            pass "Project settings.json valid ($PLUGIN_COUNT plugins)"
        else
            fail "Project settings.json has invalid JSON"
        fi
    else
        pass "Project settings.json exists"
    fi
else
    warning "No project .claude/settings.json in current directory"
fi

if [ -f "CLAUDE.md" ]; then
    LINES=$(wc -l < "CLAUDE.md")
    pass "Project CLAUDE.md ($LINES lines)"
else
    warning "No CLAUDE.md in current directory"
fi

# ── Sync System ──
header "Sync System"

if [ -d "$CONFIG_DIR/.git" ]; then
    pass "Sync repo initialized at $CONFIG_DIR"

    cd "$CONFIG_DIR"
    if git remote get-url origin &>/dev/null; then
        REMOTE=$(git remote get-url origin)
        pass "Remote configured: $REMOTE"

        # Check if we're behind
        if git fetch origin main --dry-run 2>/dev/null; then
            LOCAL=$(git rev-parse HEAD 2>/dev/null || echo "none")
            REMOTE_HEAD=$(git rev-parse origin/main 2>/dev/null || echo "none")
            if [ "$LOCAL" = "$REMOTE_HEAD" ]; then
                pass "Local and remote in sync"
            elif [ "$REMOTE_HEAD" != "none" ]; then
                warning "Local may be out of sync with remote (run ccs to sync)"
            fi
        fi
    else
        warning "No remote configured (local-only backup)"
    fi

    # Check last sync time
    if [ -f "$CONFIG_DIR/manifest.json" ] && command -v jq &>/dev/null; then
        LAST_SYNC=$(jq -r '.last_sync // "never"' "$CONFIG_DIR/manifest.json")
        pass "Last sync: $LAST_SYNC"
    fi
    cd - >/dev/null 2>&1
else
    warning "Sync system not initialized (run setup.sh)"
fi

# ── Disk Usage ──
header "Disk Usage"

if [ -d "$CLAUDE_DIR" ]; then
    SIZE=$(du -sh "$CLAUDE_DIR" 2>/dev/null | cut -f1)
    pass "~/.claude/ uses $SIZE"
fi

if [ -d "$CONFIG_DIR" ]; then
    SIZE=$(du -sh "$CONFIG_DIR" 2>/dev/null | cut -f1)
    BACKUP_COUNT=$(ls -d "$CONFIG_DIR/backups/"*/ 2>/dev/null | wc -l || echo 0)
    pass "~/.claude-config/ uses $SIZE ($BACKUP_COUNT backups)"
fi

# ── Summary ──
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Results                                 ║"
echo "╠══════════════════════════════════════════╣"
printf "║  ${GREEN}PASS: %-3s${NC}  ${YELLOW}WARN: %-3s${NC}  ${RED}FAIL: %-3s${NC}      ║\n" "$PASS" "$WARN" "$FAIL"
echo "╚══════════════════════════════════════════╝"
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}Some checks failed. Review the issues above.${NC}"
    exit 1
elif [ "$WARN" -gt 0 ]; then
    echo -e "${YELLOW}All critical checks passed, but there are warnings.${NC}"
else
    echo -e "${GREEN}All checks passed!${NC}"
fi
echo ""
