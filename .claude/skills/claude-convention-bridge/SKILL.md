---
name: claude-convention-bridge
description: >
  Use this skill whenever a user wants to sync, bridge, mirror, or port Claude Code
  conventions to any other agentic IDE, coding assistant, or LLM tool. Triggers include:
  "sync Claude with Cursor", "make Windsurf follow my Claude rules", "bridge Claude Code
  to Codex", "I use [tool] and want it to follow Claude conventions", "port my CLAUDE.md
  to [tool]", "make [tool] use my skills/hooks/rules". Also triggers when a user says they
  use multiple AI coding tools and want a single convention system. The target tool may be
  named (Cursor, Codex, Windsurf, GitHub Copilot, Cody, Continue, Aider, Zed AI, Gemini
  Code Assist, Amazon Q, JetBrains AI, Tabnine, etc.) or unnamed ("another LLM", "a
  different IDE"). Always use this skill proactively — do not wait for the user to
  specifically ask for a "skill".
---

# Claude Convention Bridge

Bridges Claude Code's convention system to any other agentic IDE or LLM tool.
The user has Claude Code as their source of truth. Your job: analyze the target
tool, map every Claude Code concept to its equivalent, generate a sync script,
and automate it so they never have to think about it again.

## Core principle

Claude Code's convention system has five pillars. Every tool has some version of
each one — different file names, different paths, different loading mechanisms.
Find the equivalent, map it, sync it.

| Claude Code concept | What it does |
|---------------------|-------------|
| `CLAUDE.md` | Persistent memory — instructions loaded every session |
| `rules/` | Modular guardrails — code style, git, security, etc. |
| `skills/*/SKILL.md` | Reusable domain knowledge loaded on demand |
| `commands/` | Repeatable task templates / slash commands |
| `settings.json` | Permissions, deny list, hooks config |
| Hooks (`PreToolUse`, `PostToolUse`, `SessionStart`) | Lifecycle automation |
| `.mcp.json` | External tool connections |

---

## Step 1 — Discover the target tool's convention system

Before writing any code, you MUST understand how the target tool loads context.
Ask the user these if you don't already know the answers:

1. What is the tool's name and version?
2. Does it have a special file it reads for instructions (like `.cursorrules`, `system_prompt.md`)?
3. Does it have a concept of "memory" or "knowledge base" that persists across sessions?
4. Does it support slash commands, workflows, or repeatable task templates?
5. Does it support hooks, triggers, or lifecycle events?
6. Does it support MCP or other external tool integrations?
7. What directory does it store its config in?

Then read `references/claude-code-conventions.md` for the full Claude Code reference,
and `references/known-mappings/` for any pre-built mapping for that tool.

**If the tool is already in `references/known-mappings/`** — load that file and proceed
to Step 3 using the existing mapping. Update the mapping if the user reports it's outdated.

**If the tool is NOT in `references/known-mappings/`** — proceed with Step 2 to build
the mapping, then save it to `known-mappings/<toolname>.md` for future use.

---

## Step 2 — Build the convention mapping

Create a mapping table for this specific tool. Read `references/bridge-patterns.md`
for the patterns to use.

For each Claude Code concept, determine:

- **Direct equivalent** — tool has the same concept, different file/path
- **Partial equivalent** — tool has something close, needs workaround
- **No equivalent** — encode as plain-language instructions in the memory file
- **Better native** — tool handles this better natively, don't override

Document the mapping as:

```
## Mapping: Claude Code → [Tool Name]

| Claude Code | [Tool] equivalent | Strategy | Notes |
|-------------|-------------------|----------|-------|
| CLAUDE.md | .cursorrules | direct | loaded globally |
| rules/*.md | .cursor/rules/*.mdc | direct | same structure |
| skills/ | no equivalent | flatten → memory file | merge all SKILL.md → one context file |
| commands/ | .cursor/prompts/ | direct | same markdown format |
| settings.json denyCommands | no equivalent | instructions in .cursorrules | can't enforce programmatically |
| PreToolUse hook | no equivalent | encode as instructions | tool has no lifecycle hooks |
| .mcp.json | mcp.json | direct | same JSON format |
```

---

## Step 3 — Generate the sync script

Read `references/bridge-patterns.md` → "Sync script template" section.

Generate a `sync.sh` that:

1. **Syncs global conventions** from `~/.claude/` to the tool's global config location
2. **Syncs per-project conventions** from `.claude/` to the tool's project config
3. **Handles skills** — either direct copy or merge into a single context file
4. **Handles rules** — direct copy or append into the tool's main instruction file
5. **Handles commands** — direct copy or format-convert as needed
6. **Extracts deny list** from `settings.json` as plain-language instructions
7. **Is idempotent** — safe to run multiple times, only copies changed files

Name the script: `~/.claude/sync/sync-<toolname>.sh`

---

## Step 4 — Automate it

Generate automation appropriate for the platform:

**macOS** — LaunchAgent + fswatch watcher (see `references/bridge-patterns.md`)
**Linux** — systemd user service + inotifywait watcher
**Windows** — Task Scheduler + PowerShell FileSystemWatcher

Also add a zsh/bash hook so syncing happens automatically on `cd` into any project.

Provide three shell aliases:
- `csync-<toolname>` — full sync now
- `csync-<toolname>-here` — sync current project only
- `csync-<toolname>-log` — tail the sync log

---

## Step 5 — Save the mapping

After building a new mapping, save it to:
`references/known-mappings/<toolname>.md`

Include:
- Tool name, version tested, date
- Full mapping table
- Any quirks or tool-specific notes
- The generated sync script path

This makes future requests for the same tool instant — just load the mapping and skip Step 2.

---

## Output checklist

Before finishing, confirm:

- [ ] `sync-<toolname>.sh` generated and explained
- [ ] Automation script generated (LaunchAgent / systemd / Task Scheduler)
- [ ] zshrc/bashrc hook snippet provided
- [ ] Shell aliases provided
- [ ] Any manual one-time steps clearly called out (e.g. "add this to Cursor's MCP settings")
- [ ] Mapping saved to `known-mappings/<toolname>.md`
- [ ] User knows where the sync log lives and how to check it

---

## Reference files

- `references/claude-code-conventions.md` — complete Claude Code convention reference
  (read this when you need full detail on any Claude Code concept)
- `references/bridge-patterns.md` — sync script templates, watcher patterns, automation
  (read this when generating scripts)
- `references/known-mappings/antigravity.md` — fully worked Antigravity example
  (read this as a reference for the expected output quality)
