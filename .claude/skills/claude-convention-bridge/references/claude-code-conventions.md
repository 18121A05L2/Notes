# Claude Code Conventions — Complete Reference

Use this file when you need full detail on any Claude Code concept before mapping it to a target tool.

---

## Memory system

### CLAUDE.md

The primary memory file. Loaded at the start of every session.

**Locations (in priority order — all are loaded and merged):**
1. `~/.claude/CLAUDE.md` — global, applies to every project
2. `<project>/CLAUDE.md` — project root, most common
3. `<project>/.claude/CLAUDE.md` — alternative project location
4. Subdirectory `CLAUDE.md` files — loaded when agent enters that directory

**What goes in it:**
- Persistent instructions the agent must always follow
- Project context: tech stack, architecture, important file locations
- Coding conventions and style preferences
- Git workflow rules
- Team-specific knowledge

**Format:** Plain markdown. No special syntax required.

**Key property:** Automatically injected into every session — user doesn't need to reference it.

---

## Rules system

### `.claude/rules/`

Modular rule files. Each file covers one domain. Referenced from CLAUDE.md or auto-loaded.

**Location:** `~/.claude/rules/` (global) or `<project>/.claude/rules/` (project)

**Naming convention:** `<domain>.md` — e.g. `code-style.md`, `git.md`, `security.md`, `testing.md`

**Format:** Plain markdown. No special syntax.

**Why modular:** Easier to maintain, easier to share individual rule sets, easier to enable/disable per project.

---

## Skills system

### `.claude/skills/<skill-name>/SKILL.md`

Reusable domain knowledge. Unlike CLAUDE.md (always loaded), skills are loaded on demand when relevant.

**Location:** `~/.claude/skills/` (global) or `<project>/.claude/skills/` (project)

**Structure:**
```
skills/
└── skill-name/
    ├── SKILL.md          ← required, loaded when skill triggers
    └── references/       ← optional, loaded when SKILL.md directs
        └── detail.md
```

**SKILL.md frontmatter:**
```yaml
---
name: skill-name
description: >
  When to trigger this skill. Written as a trigger description —
  what phrases or contexts should cause Claude to load this skill.
---
```

**Key property:** Skills are discovered by reading the `name` + `description` in frontmatter.
The agent decides whether to load a skill based on that description alone.
The body is only read when the skill triggers.

**Difference from rules:** Rules are always applied. Skills are applied only when relevant.
A "React component patterns" skill should not activate when writing Python.

---

## Commands system

### `.claude/commands/<command-name>.md`

Repeatable task templates. Invoked with `/command-name` in Claude Code.

**Location:** `~/.claude/commands/` (global) or `<project>/.claude/commands/` (project)

**Format:**
```markdown
---
description: What this command does (shown in autocomplete)
---

# Command: review-pr

You are reviewing a pull request. Do the following:

1. Check for...
2. Verify...
3. Report...
```

**Key property:** Commands are templates with fixed structure. They reduce repetitive prompting.
Global commands are available in every project. Project commands are project-specific.

---

## Settings and permissions

### `.claude/settings.json`

Controls Claude Code's behavior: what it can and cannot do.

**Location:** `~/.claude/settings.json` (global) or `<project>/.claude/settings.json` (project)

**Key fields:**
```json
{
  "permissions": {
    "allow": ["Bash(git status)", "Bash(npm run *)"],
    "deny": ["Bash(rm -rf *)", "Bash(git push --force *)"]
  },
  "denyCommands": ["rm -rf /", "git push --force origin main"],
  "env": {
    "NODE_ENV": "development"
  }
}
```

**`denyCommands`:** Shell patterns that Claude Code will refuse to execute entirely.
Supports glob patterns. This is a hard block — Claude cannot override it.

---

## Hooks system

The most powerful automation feature. Scripts that run at lifecycle events.

### Hook types

| Hook | When it fires | Common uses |
|------|--------------|-------------|
| `PreToolUse` | Before Claude uses any tool | Validate, block, inject context |
| `PostToolUse` | After Claude uses any tool | Lint, test, format, log |
| `SessionStart` | When a new session begins | Load context, check environment |
| `SessionEnd` | When session ends | Cleanup, summarize |
| `Stop` | When Claude stops naturally | Final validation |

### Hook config (in settings.json)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/pre-bash.sh"
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{
          "type": "command",
          "command": "bash ~/.claude/hooks/post-write.sh"
        }]
      }
    ]
  }
}
```

### Hook script interface

Hooks receive JSON on stdin describing the tool call. They can:
- Exit 0 — allow the action
- Exit non-zero — block the action (PreToolUse only)
- Print to stdout — inject feedback into the session

```bash
#!/bin/bash
# pre-bash.sh — reads tool input from stdin
input=$(cat)
command=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin)['tool_input']['command'])")

# Block dangerous commands
if echo "$command" | grep -q "rm -rf /"; then
  echo "ERROR: Refusing to delete root filesystem" >&2
  exit 1
fi
exit 0
```

### PreToolUse common patterns

- Block certain file paths from being edited
- Validate git branch before any write operation
- Require test files to exist before editing source
- Inject additional context before web searches

### PostToolUse common patterns

- Run type checker after editing TypeScript
- Run linter after any file write
- Run tests after editing test-adjacent files
- Sync files to another location (like this skill does)
- Log all bash commands to audit log

---

## MCP integration

### `.mcp.json`

Connects Claude Code to external tools via Model Context Protocol.

**Location:** `~/.mcp.json` (global) or `<project>/.mcp.json` (project)

**Format:**
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_..."
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/projects"]
    }
  }
}
```

**Key property:** MCP format is an open standard. Many tools support the same `.mcp.json` format,
making this one of the easiest things to sync — often a direct copy.

---

## File watching and automation

### How Claude Code discovers files

Claude Code scans these on session start:
1. Global `~/.claude/CLAUDE.md`
2. All `CLAUDE.md` files from project root to current directory
3. All active skills (reads frontmatter of each `SKILL.md` to build the skill index)
4. Settings files (merged: global settings + project settings)
5. Commands (scanned from both global and project `commands/` dirs)

### What this means for bridging

Any target tool that loads files at session start can receive synced content.
The challenge is ensuring the target tool's session start reads the right paths.

---

## Global vs project scope

Almost everything in Claude Code has two scopes:

| Scope | Path | Applies to |
|-------|------|-----------|
| Global | `~/.claude/` | Every project, every session |
| Project | `<project>/.claude/` | This project only |

Project settings override global settings where they conflict.
Project CLAUDE.md appends to global CLAUDE.md (both are loaded).

When bridging to another tool, preserve this two-scope model where possible.
