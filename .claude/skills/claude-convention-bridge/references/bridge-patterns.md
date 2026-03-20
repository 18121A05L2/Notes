# Bridge Patterns

Reusable patterns for generating sync scripts and automation. Copy and adapt these.

---

## Sync script template

Every sync script follows this structure. Replace `<TOOL>` with the target tool name,
`<TOOL_GLOBAL_DIR>` with its global config path, `<TOOL_PROJECT_DIR>` with its project path.

```bash
#!/usr/bin/env bash
# sync-<TOOL>.sh — Claude Code → <TOOL> Convention Sync
# Place at: ~/.claude/sync/sync-<TOOL>.sh

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()     { echo -e "${GREEN}✓${RESET} $1"; }
warn()   { echo -e "${YELLOW}⚠${RESET} $1"; }
info()   { echo -e "${BLUE}→${RESET} $1"; }
header() { echo -e "\n${BOLD}${CYAN}$1${RESET}"; }

CLAUDE_GLOBAL="$HOME/.claude"
TOOL_GLOBAL="<TOOL_GLOBAL_DIR>"       # e.g. ~/.cursor, ~/.config/codex
SINGLE_PROJECT="${1:-}"
VERBOSE=false
[[ "${2:-}" == "--verbose" ]] && VERBOSE=true

PROJECT_ROOTS=(
  "$HOME/Projects"
  "$HOME/Code"
  "$HOME/Developer"
  "$HOME/dev"
  "$HOME/workspace"
  "$HOME/src"
)

copy_if_changed() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ ! -f "$dst" ]] || ! diff -q "$src" "$dst" &>/dev/null; then
    cp "$src" "$dst"
    return 0
  fi
  return 1
}

sync_dir() {
  local src="$1" dst="$2" count=0
  mkdir -p "$dst"
  [[ -d "$src" ]] || return 0
  while IFS= read -r -d '' f; do
    rel="${f#$src/}"
    copy_if_changed "$f" "$dst/$rel" && (( count++ )) || true
  done < <(find "$src" -name "*.md" -type f -print0 2>/dev/null)
  echo "$count"
}

# ── ADAPT THIS FUNCTION for the target tool ───────────────────────────────────
# This is where tool-specific logic lives.
# The three strategy patterns below cover most cases.

sync_global() {
  header "Global sync (~/.claude → $TOOL_GLOBAL)"
  mkdir -p "$TOOL_GLOBAL"

  # STRATEGY A: Direct copy (tool reads from same-named file)
  # Use when: tool has a direct equivalent path
  [[ -f "$CLAUDE_GLOBAL/CLAUDE.md" ]] && \
    copy_if_changed "$CLAUDE_GLOBAL/CLAUDE.md" "$TOOL_GLOBAL/<EQUIVALENT_FILE>" && ok "CLAUDE.md"

  # STRATEGY B: Append/merge into one file (tool has one big context file)
  # Use when: tool reads a single instruction file (e.g. .cursorrules, system.md)
  # build_merged_context "$TOOL_GLOBAL/<MAIN_CONTEXT_FILE>"

  # STRATEGY C: Flatten skills into index (tool can't auto-discover directories)
  # Use when: tool doesn't traverse directories for skills
  build_skills_index "$TOOL_GLOBAL/_skills-index.md"

  # Rules — usually direct copy or append into main context
  count=$(sync_dir "$CLAUDE_GLOBAL/rules" "$TOOL_GLOBAL/rules")
  ok "Rules ($count files)"

  # Commands — usually direct copy, sometimes format conversion needed
  count=$(sync_dir "$CLAUDE_GLOBAL/commands" "$TOOL_GLOBAL/<COMMANDS_DIR>")
  ok "Commands ($count files)"

  # Deny list — always encode as plain-language instructions
  extract_deny_list "$CLAUDE_GLOBAL/settings.json" "$TOOL_GLOBAL/deny-list.md"
}

# STRATEGY B implementation: Merge everything into one context file
build_merged_context() {
  local output="$1"
  local content="# Claude Conventions\n<!-- Synced from ~/.claude/ — do not edit manually -->\n\n"

  [[ -f "$CLAUDE_GLOBAL/CLAUDE.md" ]] && content+=$(cat "$CLAUDE_GLOBAL/CLAUDE.md") && content+="\n\n"

  if [[ -d "$CLAUDE_GLOBAL/rules" ]]; then
    content+="---\n\n# Rules\n\n"
    while IFS= read -r -d '' f; do
      content+=$(cat "$f") && content+="\n\n"
    done < <(find "$CLAUDE_GLOBAL/rules" -name "*.md" -print0 2>/dev/null)
  fi

  printf "%b" "$content" > "$output"
  ok "Merged context → $output"
}

# STRATEGY C implementation: Flatten all SKILL.md files into one index
build_skills_index() {
  local output="$1"
  local skills_dir="$CLAUDE_GLOBAL/skills"
  [[ -d "$skills_dir" ]] || return 0

  local content="# Skills Index\n<!-- Synced from ~/.claude/skills/ — do not edit manually -->\n\n"
  local count=0

  while IFS= read -r -d '' skill_file; do
    local name
    name=$(basename "$(dirname "$skill_file")")
    content+="---\n\n## Skill: $name\n\n"
    content+=$(cat "$skill_file")
    content+="\n\n"
    (( count++ )) || true
  done < <(find "$skills_dir" -name "SKILL.md" -print0 2>/dev/null)

  (( count > 0 )) || return 0
  printf "%b" "$content" > "$output"
  ok "Skills index ($count skills → $output)"
}

# Deny list: extract from settings.json → plain-language instruction file
extract_deny_list() {
  local settings="$1" output="$2"
  [[ -f "$settings" ]] || return 0
  command -v python3 &>/dev/null || return 0
  python3 - "$settings" "$output" <<'EOF'
import json, sys
try:
    with open(sys.argv[1]) as f: s = json.load(f)
    denied = s.get("permissions", {}).get("deny", []) + s.get("denyCommands", [])
    if not denied: sys.exit(0)
    lines = ["# Deny list\n<!-- Synced from ~/.claude/settings.json -->\n\n"]
    lines.append("The following are FORBIDDEN and must never be executed:\n\n")
    for cmd in denied: lines.append(f"- `{cmd}`\n")
    with open(sys.argv[2], "w") as f: f.writelines(lines)
except Exception as e: print(f"Warning: {e}", file=sys.stderr)
EOF
}

# ── Per-project sync ──────────────────────────────────────────────────────────
sync_project() {
  local project="$1"
  local src="$project/.claude"
  local dst="$project/<TOOL_PROJECT_DIR>"  # e.g. .cursor/rules, .codex/

  [[ -d "$src" ]] || [[ -f "$project/CLAUDE.md" ]] || return 0

  mkdir -p "$dst"
  local total=0

  [[ -f "$project/CLAUDE.md" ]] && \
    copy_if_changed "$project/CLAUDE.md" "$dst/<EQUIV_FILE>" && (( total++ )) || true

  [[ -d "$src/rules" ]] && { count=$(sync_dir "$src/rules" "$dst/rules"); (( total+=count )) || true; }
  [[ -d "$src/commands" ]] && { count=$(sync_dir "$src/commands" "$dst/<COMMANDS_DIR>"); (( total+=count )) || true; }

  if [[ -d "$src/skills" ]]; then
    local pindex="$dst/_skills-index.md"
    local sc=0 c=""
    while IFS= read -r -d '' f; do
      c+="---\n\n## Skill: $(basename "$(dirname "$f")")\n\n$(cat "$f")\n\n"
      (( sc++ )) || true
    done < <(find "$src/skills" -name "SKILL.md" -print0 2>/dev/null)
    (( sc > 0 )) && printf "%b" "$c" > "$pindex" && (( total+=sc )) || true
  fi

  (( total > 0 )) && ok "  $(basename "$project") ($total items)" || true
}

sync_all_projects() {
  header "Project sync"
  local found=0
  for root in "${PROJECT_ROOTS[@]}"; do
    [[ -d "$root" ]] || continue
    while IFS= read -r -d '' project; do
      sync_project "$project"
      (( found++ )) || true
    done < <(find "$root" -maxdepth 3 \( -name ".claude" -o -name "CLAUDE.md" \) -print0 2>/dev/null \
             | sed -z 's|/\.claude$||' | sed -z 's|/CLAUDE\.md$||' | sort -z -u)
  done
  info "$found project(s) scanned."
}

main() {
  echo -e "${BOLD}${CYAN}Claude Code → <TOOL> Sync${RESET}\n"
  sync_global
  if [[ -n "$SINGLE_PROJECT" ]]; then
    sync_project "$SINGLE_PROJECT"
  else
    sync_all_projects
  fi
  echo -e "\n${GREEN}${BOLD}Done.${RESET}"
}

main "$@"
```

---

## File watcher template (macOS — fswatch)

```bash
#!/usr/bin/env bash
# watch-<TOOL>.sh
SYNC_SCRIPT="$HOME/.claude/sync/sync-<TOOL>.sh"
LOG="$HOME/.claude/sync/sync-<TOOL>.log"
DEBOUNCE=2

[[ -x "$SYNC_SCRIPT" ]] || chmod +x "$SYNC_SCRIPT"

WATCH_PATHS=("$HOME/.claude")
for root in "$HOME/Projects" "$HOME/Code" "$HOME/Developer" "$HOME/dev"; do
  [[ -d "$root" ]] && WATCH_PATHS+=("$root")
done

LAST=0
fswatch --recursive --latency 1.0 \
  --event Created --event Updated --event Renamed \
  --include '.*\.md$' --include '.*settings\.json$' \
  "${WATCH_PATHS[@]}" | while IFS= read -r file; do

  [[ "$file" == *"/.claude/"* ]] || [[ "$file" == *"/CLAUDE.md" ]] || continue
  NOW=$(date +%s)
  (( NOW - LAST < DEBOUNCE )) && continue
  LAST=$NOW

  project=$(echo "$file" | sed 's|/.claude/.*||' | sed 's|/CLAUDE.md||')

  if [[ "$file" == "$HOME/.claude/"* ]]; then
    bash "$SYNC_SCRIPT" >> "$LOG" 2>&1
  elif [[ -d "$project/.claude" ]]; then
    bash "$SYNC_SCRIPT" "$project" >> "$LOG" 2>&1
  fi
done
```

---

## File watcher template (Linux — inotifywait)

```bash
#!/usr/bin/env bash
# watch-<TOOL>.sh (Linux)
SYNC_SCRIPT="$HOME/.claude/sync/sync-<TOOL>.sh"
LOG="$HOME/.claude/sync/sync-<TOOL>.log"

inotifywait -m -r \
  --event modify,create,moved_to \
  --include '.*\.(md|json)$' \
  "$HOME/.claude" \
  | while read -r dir event file; do
    [[ "$file" =~ \.(md|json)$ ]] || continue
    project_dir="$dir"
    if [[ "$dir" == "$HOME/.claude/"* ]]; then
      bash "$SYNC_SCRIPT" >> "$LOG" 2>&1
    else
      bash "$SYNC_SCRIPT" "${project_dir%%/.claude/*}" >> "$LOG" 2>&1
    fi
  done
```

---

## LaunchAgent template (macOS)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.claude.sync-<TOOL></string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string><string>-l</string><string>-c</string>
    <string>exec bash "$HOME/.claude/sync/watch-<TOOL>.sh"</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>ThrottleInterval</key><integer>10</integer>
  <key>StandardOutPath</key>
  <string>/Users/USERNAME/.claude/sync/<TOOL>-stdout.log</string>
  <key>StandardErrorPath</key>
  <string>/Users/USERNAME/.claude/sync/<TOOL>-stderr.log</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>HOME</key><string>/Users/USERNAME</string>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
  </dict>
</dict>
</plist>
```

---

## systemd user service template (Linux)

```ini
# ~/.config/systemd/user/claude-sync-<TOOL>.service
[Unit]
Description=Claude Code → <TOOL> convention sync watcher
After=default.target

[Service]
ExecStart=/bin/bash -l %h/.claude/sync/watch-<TOOL>.sh
Restart=on-failure
RestartSec=5
StandardOutput=append:%h/.claude/sync/sync-<TOOL>.log
StandardError=append:%h/.claude/sync/sync-<TOOL>.log

[Install]
WantedBy=default.target
```

```bash
# Enable and start
systemctl --user enable claude-sync-<TOOL>.service
systemctl --user start claude-sync-<TOOL>.service
```

---

## zsh/bash hook template

```bash
# Add to ~/.zshrc or ~/.bashrc
# ─── Claude → <TOOL> sync on cd ───────────────────────────────────────────────
_claude_<TOOL>_sync_on_cd() {
  local dir="$PWD"
  while [[ "$dir" != "$HOME" ]] && [[ "$dir" != "/" ]]; do
    [[ -d "$dir/.claude" ]] || [[ -f "$dir/CLAUDE.md" ]] && break
    dir="$(dirname "$dir")"
  done
  [[ -d "$dir/.claude" ]] || [[ -f "$dir/CLAUDE.md" ]] || return 0
  [[ -x "$HOME/.claude/sync/sync-<TOOL>.sh" ]] || return 0

  local stamp="$HOME/.claude/sync/.stamps/$(echo "$dir" | md5).stamp"
  mkdir -p "$(dirname "$stamp")"
  local run=false
  [[ ! -f "$stamp" ]] && run=true
  [[ -n "$(find "$dir/.claude" -newer "$stamp" 2>/dev/null | head -1)" ]] && run=true
  $run || return 0

  (bash "$HOME/.claude/sync/sync-<TOOL>.sh" "$dir" \
    >> "$HOME/.claude/sync/sync-<TOOL>.log" 2>&1 && touch "$stamp") &
  disown
}

# zsh
autoload -U add-zsh-hook
add-zsh-hook chpwd _claude_<TOOL>_sync_on_cd
_claude_<TOOL>_sync_on_cd

# Aliases
alias csync-<TOOL>="bash $HOME/.claude/sync/sync-<TOOL>.sh"
alias csync-<TOOL>-here="bash $HOME/.claude/sync/sync-<TOOL>.sh $PWD"
alias csync-<TOOL>-log="tail -f $HOME/.claude/sync/sync-<TOOL>.log"
# ──────────────────────────────────────────────────────────────────────────────
```

---

## Strategy decision guide

Use this to pick the right sync strategy for each Claude Code concept:

```
Does the target tool load this file type natively?
├── Yes, same format, different path → DIRECT COPY
├── Yes, different format → FORMAT CONVERT then copy
├── Partial (one big file instead of many) → MERGE/APPEND into that file
└── No → ENCODE AS INSTRUCTIONS in the main memory file

Does the target tool support hooks/lifecycle events?
├── Yes (and format is compatible) → MAP hooks directly
├── Partial → MAP what you can, encode the rest as instructions
└── No → Encode all hook behaviors as plain-language rules in CLAUDE.md equivalent

Does the target tool support MCP?
├── Yes → DIRECT COPY .mcp.json (it's an open standard)
└── No → Document available integrations in memory file
```

---

## Known tool config locations

Quick reference for common tools. Verify — these change with updates.

| Tool | Global config | Project config | Memory file | Commands |
|------|--------------|----------------|-------------|---------|
| Cursor | `~/.cursor/` | `.cursor/` | `.cursorrules` | `.cursor/prompts/` |
| Windsurf | `~/.codeium/windsurf/` | `.windsurf/` | `.windsurfrules` | — |
| GitHub Copilot | `~/.config/gh-copilot/` | `.github/copilot-instructions.md` | `.github/copilot-instructions.md` | — |
| Continue | `~/.continue/` | `.continue/` | `config.json` system prompt | `.continue/prompts/` |
| Aider | `~/.aider.conf.yml` | `.aider.conf.yml` | `--system-prompt` field | — |
| Cody (Sourcegraph) | VS Code settings | `.sourcegraph/` | `cody.md` | — |
| Amazon Q | `~/.aws/amazonq/` | `.amazonq/` | `system_prompt` | — |
| JetBrains AI | IDE settings | `.idea/` | AI Instructions setting | — |
| Zed AI | `~/.config/zed/` | `.zed/` | `assistant.default_model` | — |
| Gemini Code Assist | `~/.config/gemini/` | `.gemini/` | `GEMINI.md` | — |
| Codex (OpenAI) | `~/.codex/` | `.codex/` | `AGENTS.md` | — |

**Note:** Always verify paths before generating a sync script. Tools update frequently.
When uncertain, ask the user to check their tool's settings panel or run `find ~ -name "*.rules" -o -name "*.md" | grep -i "cursor\|copilot\|windsurf" 2>/dev/null | head -20`.
