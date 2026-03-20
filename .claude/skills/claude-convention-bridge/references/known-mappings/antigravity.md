# Known Mapping: Antigravity

**Tool:** Antigravity (multi-LLM agentic coding assistant)
**Config format:** Markdown files, Knowledge Items (KI)
**Last verified:** 2026

---

## Convention mapping

| Claude Code | Antigravity equivalent | Strategy | Notes |
|-------------|------------------------|----------|-------|
| `~/.claude/CLAUDE.md` | `~/.gemini/brain/CLAUDE.md` | Direct copy | KI loaded at session start |
| `~/.claude/rules/*.md` | `~/.gemini/brain/rules/*.md` | Direct copy | Each rule file = one KI |
| `~/.claude/skills/*/SKILL.md` | `~/.gemini/brain/_skills-index.md` | Flatten → one KI | AG can't traverse directories |
| `~/.claude/commands/*.md` | `~/.gemini/brain/commands/*.md` | Direct copy | Treated as workflow templates |
| `settings.json` denyCommands | `~/.gemini/brain/deny-list.md` | Extract → instructions | No programmatic enforcement |
| `PreToolUse` hook | None | Encode in CLAUDE.md | No lifecycle hooks |
| `PostToolUse` hook | None | Encode in CLAUDE.md | No lifecycle hooks |
| `.mcp.json` | Settings panel | Manual setup | AG reads MCP from UI, not file |
| `<project>/CLAUDE.md` | `<project>/.gemini/antigravity/brain/CLAUDE.md` | Direct copy | Per-project KI |
| `<project>/.claude/rules/` | `<project>/.gemini/antigravity/brain/rules/` | Direct copy | Per-project |
| `<project>/.claude/commands/` | `<project>/.gemini/antigravity/brain/commands/` + `<project>/.agents/workflows/` | Direct copy | Mirror to both locations |

---

## Quirks and notes

- **Skills must be flattened.** Antigravity's Knowledge Item system loads individual files,
  not directories. The sync script builds `_skills-index.md` by concatenating all SKILL.md
  files with section headers. Antigravity picks this up as one KI.

- **No hook equivalent.** Antigravity has no `PreToolUse`/`PostToolUse` system. Encode
  hook-equivalent behavior as plain language in CLAUDE.md:
  ```markdown
  ## Execution rules
  Before editing any file: verify the git branch is not main.
  After editing TypeScript: run npx tsc --noEmit.
  ```

- **MCP is configured via the Antigravity settings panel**, not via a file. The sync
  script cannot automate this. Tell the user to configure MCP manually in the UI.

- **Session start:** Antigravity loads all KIs at session start. New sessions will always
  have the latest synced content. Changes are NOT reflected mid-session.

- **Brain directory path:** `~/.gemini/brain/` for global, `.gemini/antigravity/brain/`
  for per-project. The nested path is a quirk of how Antigravity stores project KIs.

---

## Sync script location

`~/.claude/sync/sync.sh` (handles both global and all-projects sync)

## Automation

- **Watcher:** `~/.claude/sync/watch.sh` via fswatch
- **Daemon:** `~/Library/LaunchAgents/com.claude.sync.plist`
- **Shell hook:** zsh `chpwd` + stamp files (avoids syncing unchanged projects)
- **Log:** `~/.claude/sync/sync.log`

## Aliases

```bash
csync           # full sync: global + all projects
csync-here      # sync current project only
csync-log       # tail sync log
```
