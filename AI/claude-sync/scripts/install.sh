#!/usr/bin/env bash
# =============================================================================
# install.sh — One-command setup for Claude Code → Antigravity sync on Mac
# =============================================================================
# Usage: bash install.sh
# =============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()     { echo -e "${GREEN}✓${RESET} $1"; }
warn()   { echo -e "${YELLOW}⚠${RESET} $1"; }
info()   { echo -e "${BLUE}→${RESET} $1"; }
fail()   { echo -e "${RED}✗${RESET} $1"; exit 1; }
header() { echo -e "\n${BOLD}${CYAN}$1${RESET}"; }

INSTALL_DIR="$HOME/.claude/sync"
LAUNCHD_PLIST="$HOME/Library/LaunchAgents/com.claude.sync.plist"
ZSHRC="$HOME/.zshrc"
USERNAME=$(whoami)

echo -e "${BOLD}${CYAN}"
echo "  Claude Code → Antigravity Sync — Installer"
echo -e "${RESET}"

# ── 1. Check dependencies ─────────────────────────────────────────────────────
header "1/6  Checking dependencies"

if ! command -v brew &>/dev/null; then
  fail "Homebrew not found. Install from https://brew.sh first."
fi
ok "Homebrew"

if ! command -v fswatch &>/dev/null; then
  info "Installing fswatch..."
  brew install fswatch
fi
ok "fswatch $(fswatch --version 2>&1 | head -1)"

# ── 2. Create install dir ─────────────────────────────────────────────────────
header "2/6  Installing scripts"

mkdir -p "$INSTALL_DIR" "$INSTALL_DIR/.stamps"

# Copy scripts from wherever this installer lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp "$SCRIPT_DIR/sync.sh"  "$INSTALL_DIR/sync.sh"
cp "$SCRIPT_DIR/watch.sh" "$INSTALL_DIR/watch.sh"
chmod +x "$INSTALL_DIR/sync.sh" "$INSTALL_DIR/watch.sh"

ok "sync.sh → $INSTALL_DIR/sync.sh"
ok "watch.sh → $INSTALL_DIR/watch.sh"

# ── 3. Create global CLAUDE.md if missing ─────────────────────────────────────
header "3/6  Global CLAUDE.md"

if [[ ! -f "$HOME/.claude/CLAUDE.md" ]]; then
  mkdir -p "$HOME/.claude"
  cat > "$HOME/.claude/CLAUDE.md" <<'CLAUDE_MD'
# Global Claude Instructions

This file is loaded by Claude Code in every session and synced to Antigravity.

## Code style
- Prefer explicit over implicit
- Write self-documenting code; comments explain *why*, not *what*
- Keep functions small and single-purpose

## Git
- Never commit directly to main/master
- Use conventional commits: feat:, fix:, chore:, docs:, refactor:
- Always run tests before committing

## Tools
- Prefer project-local tools (npx, python -m) over global installs
- Check for existing abstractions before creating new ones
CLAUDE_MD
  ok "Created ~/.claude/CLAUDE.md (edit this to add your global rules)"
else
  ok "~/.claude/CLAUDE.md already exists"
fi

# ── 4. Install LaunchAgent ─────────────────────────────────────────────────────
header "4/6  LaunchAgent (background watcher)"

PLIST_SRC="$SCRIPT_DIR/../launchagent/com.claude.sync.plist"

if [[ -f "$PLIST_SRC" ]]; then
  # Replace placeholder username
  sed "s|REPLACE_WITH_USERNAME|$USERNAME|g" "$PLIST_SRC" > "$LAUNCHD_PLIST"
else
  # Generate plist inline
  cat > "$LAUNCHD_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.claude.sync</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-l</string>
    <string>-c</string>
    <string>exec bash "$HOME/.claude/sync/watch.sh"</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>ThrottleInterval</key>
  <integer>10</integer>
  <key>StandardOutPath</key>
  <string>/Users/$USERNAME/.claude/sync/launchd-stdout.log</string>
  <key>StandardErrorPath</key>
  <string>/Users/$USERNAME/.claude/sync/launchd-stderr.log</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>HOME</key>
    <string>/Users/$USERNAME</string>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
  </dict>
</dict>
</plist>
PLIST
fi

# Unload existing agent if running
launchctl unload "$LAUNCHD_PLIST" 2>/dev/null || true
launchctl load "$LAUNCHD_PLIST"

ok "LaunchAgent loaded (auto-starts on login)"

# ── 5. Add zsh hook ────────────────────────────────────────────────────────────
header "5/6  Shell hook (~/.zshrc)"

HOOK_MARKER="# >>> claude-antigravity-sync <<<"
HOOK_END="# <<< claude-antigravity-sync <<<"

if grep -q "$HOOK_MARKER" "$ZSHRC" 2>/dev/null; then
  ok ".zshrc hook already present"
else
  cat >> "$ZSHRC" <<ZSHRC_BLOCK

$HOOK_MARKER
CLAUDE_SYNC_SCRIPT="\$HOME/.claude/sync/sync.sh"
CLAUDE_SYNC_STAMP_DIR="\$HOME/.claude/sync/.stamps"

_claude_sync_on_cd() {
  local dir="\$PWD"
  while [[ "\$dir" != "\$HOME" ]] && [[ "\$dir" != "/" ]]; do
    [[ -d "\$dir/.claude" ]] || [[ -f "\$dir/CLAUDE.md" ]] && break
    dir="\$(dirname "\$dir")"
  done
  [[ -d "\$dir/.claude" ]] || [[ -f "\$dir/CLAUDE.md" ]] || return 0
  [[ -x "\$CLAUDE_SYNC_SCRIPT" ]] || return 0
  local stamp_file="\$CLAUDE_SYNC_STAMP_DIR/\$(echo "\$dir" | md5).stamp"
  mkdir -p "\$CLAUDE_SYNC_STAMP_DIR"
  local should_run=false
  [[ ! -f "\$stamp_file" ]] && should_run=true
  [[ -n "\$(find "\$dir/.claude" -newer "\$stamp_file" 2>/dev/null | head -1)" ]] && should_run=true
  \$should_run || return 0
  (bash "\$CLAUDE_SYNC_SCRIPT" --project="\$dir" \
    >> "\$HOME/.claude/sync/sync.log" 2>&1 && touch "\$stamp_file") &
  disown
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _claude_sync_on_cd
_claude_sync_on_cd

alias csync="bash \$HOME/.claude/sync/sync.sh"
alias csync-here="bash \$HOME/.claude/sync/sync.sh --project=\$PWD"
alias csync-log="tail -f \$HOME/.claude/sync/sync.log"
$HOOK_END
ZSHRC_BLOCK

  ok ".zshrc updated with sync hook + aliases"
fi

# ── 6. First sync ──────────────────────────────────────────────────────────────
header "6/6  Running first sync"

bash "$INSTALL_DIR/sync.sh" --verbose

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}Installation complete!${RESET}"
echo ""
echo -e "  ${CYAN}Aliases added to ~/.zshrc:${RESET}"
echo -e "    ${BOLD}csync${RESET}       — full sync now"
echo -e "    ${BOLD}csync-here${RESET}  — sync current project"
echo -e "    ${BOLD}csync-log${RESET}   — watch the live sync log"
echo ""
echo -e "  ${CYAN}Background watcher:${RESET}"
echo -e "    launchctl list | grep claude"
echo -e "    tail -f ~/.claude/sync/sync.log"
echo ""
echo -e "  ${CYAN}To reload shell hook:${RESET}"
echo -e "    source ~/.zshrc"
echo ""
