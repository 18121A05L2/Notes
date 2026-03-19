# Claude Code → Antigravity Sync

> One convention to rule them all. Keep Claude Code as your source of truth — Antigravity follows automatically.

---

## What this is

Claude Code has a rich convention system: `CLAUDE.md` for persistent memory, hooks for automation, skills for reusable knowledge, commands for repeatable tasks, and rules for modular guardrails. Antigravity supports different LLMs but has no equivalent structure.

This setup **bridges the two** — you write your conventions once in Claude Code's format, and everything syncs to Antigravity automatically. No manual pointing, no duplicate files, no drift between tools.

---

## How it works

Three automation layers run together:

```
You edit .claude/ or CLAUDE.md
        ↓
  fswatch detects the change (within 1–2 seconds)
        ↓
  watch.sh triggers sync.sh
        ↓
  Antigravity brain/ updated automatically
```

Plus two additional triggers:

- **On `cd`** — zsh hook checks if the project changed since last sync, syncs in background
- **On login** — LaunchAgent starts the watcher automatically, no manual action needed

---

## File structure

After install, your setup looks like this:

```
~/.claude/                          ← Claude Code global config (your source of truth)
│
├── CLAUDE.md                       ← Global instructions loaded in every session
├── rules/                          ← Modular rules (code style, security, git, etc.)
│   ├── code-style.md
│   ├── git.md
│   └── security.md
├── skills/                         ← Reusable knowledge loaded on demand
│   └── your-skill/
│       └── SKILL.md
├── commands/                       ← Slash commands / repeatable task templates
│   └── review.md
├── settings.json                   ← Permissions, deny list, hooks config
└── sync/                           ← This tool lives here
    ├── sync.sh                     ← Main sync script
    ├── watch.sh                    ← File watcher daemon
    ├── sync.log                    ← Live log of all sync activity
    └── .stamps/                    ← Tracks last-sync timestamps per project

~/.gemini/brain/                    ← Auto-populated by sync.sh (Antigravity KI)
├── CLAUDE.md                       ← Mirror of ~/.claude/CLAUDE.md
├── rules/                          ← Mirror of ~/.claude/rules/
├── commands/                       ← Mirror of ~/.claude/commands/
├── _skills-index.md                ← All SKILL.md files merged into one KI
└── deny-list.md                    ← Extracted from settings.json denyCommands

~/Library/LaunchAgents/
└── com.claude.sync.plist           ← macOS daemon (auto-starts watcher on login)

Per project:
<project>/
├── CLAUDE.md                       ← Project-specific instructions
├── .claude/
│   ├── rules/                      ← Project rules (merged with global on sync)
│   ├── commands/                   ← Project commands
│   └── skills/                     ← Project-specific skills
└── .gemini/antigravity/brain/      ← Auto-populated from .claude/
    ├── CLAUDE.md
    ├── rules/
    ├── commands/
    └── _skills-index.md
```

---

## Installation

### Prerequisites

- macOS (uses LaunchAgents for daemon management)
- [Homebrew](https://brew.sh)
- zsh (default on macOS Catalina+)

### One-command install

```bash
bash ~/Downloads/claude-sync/scripts/install.sh
```

The installer does the following in order:

1. Checks for Homebrew, installs `fswatch` if missing
2. Copies `sync.sh` and `watch.sh` to `~/.claude/sync/`
3. Creates `~/.claude/CLAUDE.md` if it doesn't exist yet
4. Installs and loads the LaunchAgent (`com.claude.sync.plist`)
5. Adds the zsh hook and aliases to `~/.zshrc`
6. Runs the first full sync

### After install

```bash
source ~/.zshrc          # reload shell to activate aliases
```

That's it. The watcher is running in the background from this point on.

---

## Configuration

### Add your project directories

Open `~/.claude/sync/sync.sh` and update `PROJECT_ROOTS`:

```bash
PROJECT_ROOTS=(
  "$HOME/Projects"      # ← add your actual project dirs here
  "$HOME/Code"
  "$HOME/dev"
)
```

After saving, run `csync` once to scan the new roots.

### Global CLAUDE.md

`~/.claude/CLAUDE.md` is loaded in every Claude Code session globally, and synced to Antigravity's brain as the base context. Edit it to add your universal coding preferences, git conventions, tool preferences, and anything you want both tools to always know.

```markdown
# Global Claude Instructions

## Code style
- Prefer explicit over implicit
- Write self-documenting code; comments explain *why*, not *what*

## Git
- Never commit directly to main/master
- Use conventional commits: feat:, fix:, chore:, docs:, refactor:

## Tools
- Prefer project-local tools (npx, python -m) over global installs
```

### Project CLAUDE.md

Each project can have its own `CLAUDE.md` at the project root. This is for project-specific context — tech stack, architecture decisions, important file locations, team conventions. Gets synced to `.gemini/antigravity/brain/CLAUDE.md` in that project.

### Rules (modular guardrails)

Break your conventions into separate files in `~/.claude/rules/` so they're easier to maintain:

```
~/.claude/rules/
├── code-style.md     # formatting, naming, patterns
├── git.md            # branching, commit format, PR rules
├── security.md       # what never to do, secrets handling
└── testing.md        # coverage expectations, test naming
```

All rule files sync to Antigravity's brain automatically.

### Skills (reusable knowledge)

Skills are markdown files that teach the agent a specific technique or domain. Claude Code discovers them via `SKILL.md` inside named folders. Antigravity doesn't auto-discover directories, so `sync.sh` merges all your skills into one `_skills-index.md` Knowledge Item that Antigravity loads at session start.

```
~/.claude/skills/
└── your-skill-name/
    └── SKILL.md        ← content goes here
```

### Hooks (pre/post execution)

Claude Code hooks have no direct Antigravity equivalent. Use two approaches in parallel:

**Hard rules** (things that must never happen) — add to `~/.claude/settings.json`:

```json
{
  "permissions": {
    "denyCommands": ["rm -rf /", "git push --force origin main"]
  }
}
```

`sync.sh` extracts these into `~/.gemini/brain/deny-list.md` so Antigravity sees them as instructions.

**Soft rules** (validation, formatting, test-before-commit) — encode in `CLAUDE.md` so both tools read them:

```markdown
## Execution rules
Before editing any file:
- Verify git branch is not `main`

After editing any TypeScript file:
- Run: npx tsc --noEmit

After editing any Python file:
- Run: black --check <file>
```

---

## Aliases

| Alias | What it does |
|-------|-------------|
| `csync` | Full sync: global conventions + all projects in PROJECT_ROOTS |
| `csync-here` | Sync only the current project (fast) |
| `csync-log` | Tail the live sync log |

---

## What syncs where

| Claude Code | Antigravity | Notes |
|-------------|-------------|-------|
| `~/.claude/CLAUDE.md` | `~/.gemini/brain/CLAUDE.md` | Global instructions |
| `~/.claude/rules/*.md` | `~/.gemini/brain/rules/` | All rule files |
| `~/.claude/skills/*/SKILL.md` | `~/.gemini/brain/_skills-index.md` | Merged into one KI |
| `~/.claude/commands/*.md` | `~/.gemini/brain/commands/` | Also mirrored to `.agents/workflows/` |
| `settings.json` denyCommands | `~/.gemini/brain/deny-list.md` | Extracted as instructions |
| `<project>/CLAUDE.md` | `<project>/.gemini/antigravity/brain/CLAUDE.md` | Per-project |
| `<project>/.claude/rules/` | `<project>/.gemini/antigravity/brain/rules/` | Per-project |
| `<project>/.claude/skills/` | `<project>/.gemini/antigravity/brain/_skills-index.md` | Per-project |
| `<project>/.claude/commands/` | `<project>/.gemini/antigravity/brain/commands/` + `.agents/workflows/` | Per-project |

---

## Troubleshooting

### Sync isn't triggering automatically

Check if the watcher is running:

```bash
launchctl list | grep claude
```

Check the log for errors:

```bash
csync-log
```

Restart the watcher:

```bash
launchctl unload ~/Library/LaunchAgents/com.claude.sync.plist
launchctl load ~/Library/LaunchAgents/com.claude.sync.plist
```

### A project isn't being picked up

Make sure the project directory is under one of the `PROJECT_ROOTS` in `sync.sh`, or has a `.git` folder within 4 levels of `$HOME`. Then run `csync` to force a scan.

### Antigravity isn't picking up changes

Antigravity loads Knowledge Items at session start. After a sync, start a new Antigravity session to get the updated context. You can verify the sync happened by checking:

```bash
ls -la ~/.gemini/brain/
```

### Aliases not found after install

```bash
source ~/.zshrc
```

### fswatch not found

```bash
brew install fswatch
```

---

## Manual sync (no watcher)

If you prefer not to run a background daemon, you can skip the LaunchAgent and just use the sync script manually:

```bash
# Full sync
bash ~/.claude/sync/sync.sh

# Single project
bash ~/.claude/sync/sync.sh --project=/path/to/your/project

# Verbose output
bash ~/.claude/sync/sync.sh --verbose
```

To unload the background daemon:

```bash
launchctl unload ~/Library/LaunchAgents/com.claude.sync.plist
```

---

## Files in this repo

```
claude-sync/
├── scripts/
│   ├── install.sh          ← Run this first, sets everything up
│   ├── sync.sh             ← Main sync logic, configure PROJECT_ROOTS here
│   ├── watch.sh            ← fswatch daemon, called by LaunchAgent
│   └── zshrc-additions.sh  ← Shell hook + aliases (install.sh adds these automatically)
└── launchagent/
    └── com.claude.sync.plist   ← macOS LaunchAgent definition
```
