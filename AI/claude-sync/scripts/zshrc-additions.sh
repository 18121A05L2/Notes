# =============================================================================
# Claude Code → Antigravity: project-level auto-sync hook
# Add this block to your ~/.zshrc
# =============================================================================
# When you cd into a project that has .claude/, it auto-syncs that project
# to Antigravity if anything has changed since last sync.
# =============================================================================

CLAUDE_SYNC_SCRIPT="$HOME/.claude/sync/sync.sh"
CLAUDE_SYNC_STAMP_DIR="$HOME/.claude/sync/.stamps"

_claude_sync_on_cd() {
  local dir="$PWD"

  # Walk up to find project root with .claude/
  while [[ "$dir" != "$HOME" ]] && [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.claude" ]] || [[ -f "$dir/CLAUDE.md" ]]; then
      break
    fi
    dir="$(dirname "$dir")"
  done

  [[ -d "$dir/.claude" ]] || [[ -f "$dir/CLAUDE.md" ]] || return 0
  [[ -x "$CLAUDE_SYNC_SCRIPT" ]] || return 0

  # Stamp file — only re-sync if .claude/ is newer than the stamp
  local stamp_file="$CLAUDE_SYNC_STAMP_DIR/$(echo "$dir" | md5).stamp"
  mkdir -p "$CLAUDE_SYNC_STAMP_DIR"

  local should_run=false
  if [[ ! -f "$stamp_file" ]]; then
    should_run=true
  elif [[ -n "$(find "$dir/.claude" "$dir/CLAUDE.md" \
                 -newer "$stamp_file" 2>/dev/null | head -1)" ]]; then
    should_run=true
  fi

  if $should_run; then
    # Run in background so it doesn't block your prompt
    (bash "$CLAUDE_SYNC_SCRIPT" --project="$dir" \
      >> "$HOME/.claude/sync/sync.log" 2>&1 \
      && touch "$stamp_file") &
    disown
  fi
}

# Hook into zsh's chpwd — fires on every cd
autoload -U add-zsh-hook
add-zsh-hook chpwd _claude_sync_on_cd

# Also fire once when shell starts (covers re-opening terminal in a project)
_claude_sync_on_cd

# Optional: manual aliases
alias csync="bash $CLAUDE_SYNC_SCRIPT"                    # full sync
alias csync-here="bash $CLAUDE_SYNC_SCRIPT --project=$PWD" # sync current project
alias csync-log="tail -f $HOME/.claude/sync/sync.log"      # watch sync log
# =============================================================================
