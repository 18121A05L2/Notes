#!/usr/bin/env bash
# =============================================================================
# watch.sh — Auto-trigger sync.sh on any Claude Code file change
# =============================================================================
# Uses fswatch (brew install fswatch) to watch:
#   - ~/.claude/  (global)
#   - Any active project's .claude/ directory
# Place at: ~/.claude/sync/watch.sh
# This is called by the LaunchAgent, not run manually.
# =============================================================================

set -euo pipefail

SYNC_SCRIPT="${HOME}/.claude/sync/sync.sh"
LOG_FILE="${HOME}/.claude/sync/sync.log"
DEBOUNCE_SECS=2  # wait 2s after last change before syncing (batch rapid edits)

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

# Rotate log if > 1MB
if [[ -f "$LOG_FILE" ]] && (( $(stat -f%z "$LOG_FILE" 2>/dev/null || echo 0) > 1048576 )); then
  mv "$LOG_FILE" "${LOG_FILE}.old"
fi

log "Watcher started (PID $$)"

if ! command -v fswatch &>/dev/null; then
  log "ERROR: fswatch not found. Install with: brew install fswatch"
  exit 1
fi

if [[ ! -x "$SYNC_SCRIPT" ]]; then
  chmod +x "$SYNC_SCRIPT"
fi

# ── Build watch paths ─────────────────────────────────────────────────────────
WATCH_PATHS=("$HOME/.claude")

# Add project roots (non-recursive at top level, fswatch handles depth)
for root in \
  "$HOME/Projects" "$HOME/Code" "$HOME/Developer" \
  "$HOME/dev" "$HOME/workspace" "$HOME/src"; do
  [[ -d "$root" ]] && WATCH_PATHS+=("$root")
done

log "Watching: ${WATCH_PATHS[*]}"

# ── Debounce logic ────────────────────────────────────────────────────────────
LAST_TRIGGER=0
PENDING_PROJECT=""

should_sync() {
  local file="$1"
  # Only care about .md files inside .claude/ dirs, or settings.json
  [[ "$file" == *"/.claude/"* ]] || [[ "$file" == *"/CLAUDE.md" ]] || return 1
  [[ "$file" == *".md" ]] || [[ "$file" == *"settings.json" ]] || return 1
  return 0
}

extract_project() {
  local file="$1"
  # Get the project root from the file path
  echo "$file" | sed 's|/.claude/.*||' | sed 's|/CLAUDE.md||'
}

# ── Watch loop ────────────────────────────────────────────────────────────────
fswatch \
  --recursive \
  --event Created --event Updated --event Renamed --event Removed \
  --include '.*\.md$' \
  --include '.*settings\.json$' \
  --include '.*CLAUDE\.md$' \
  --latency 1.0 \
  "${WATCH_PATHS[@]}" | while IFS= read -r changed_file; do

  should_sync "$changed_file" || continue

  NOW=$(date +%s)
  ELAPSED=$(( NOW - LAST_TRIGGER ))

  if (( ELAPSED < DEBOUNCE_SECS )); then
    continue  # Too soon — skip, next event will catch it
  fi

  LAST_TRIGGER=$NOW
  project=$(extract_project "$changed_file")

  log "Changed: $changed_file"

  if [[ "$changed_file" == "$HOME/.claude/"* ]]; then
    # Global change → full global sync + all projects
    log "Triggering full sync..."
    bash "$SYNC_SCRIPT" >> "$LOG_FILE" 2>&1 && log "Full sync OK" || log "Sync error (see above)"
  elif [[ -n "$project" ]] && [[ -d "$project/.claude" ]]; then
    # Project-level change → sync that project only (fast)
    log "Triggering project sync: $project"
    bash "$SYNC_SCRIPT" --project="$project" >> "$LOG_FILE" 2>&1 \
      && log "Project sync OK: $(basename "$project")" \
      || log "Sync error for $project"
  fi

done
