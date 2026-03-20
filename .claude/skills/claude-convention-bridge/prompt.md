# Prompt: Claude Convention Bridge

Use this prompt when you want to sync Claude Code conventions to any other agentic IDE or LLM tool.
Paste the entire prompt block into your conversation, then tell Claude which tool you want to bridge.

---

## The prompt

```
I use Claude Code as my primary agentic coding environment and want to keep its 
convention system as my single source of truth. I now want to bridge these 
conventions to [TARGET TOOL].

My Claude Code conventions live in:
- ~/.claude/CLAUDE.md         — global instructions
- ~/.claude/rules/            — modular guardrails
- ~/.claude/skills/           — reusable domain knowledge
- ~/.claude/commands/         — repeatable task templates
- ~/.claude/settings.json     — permissions and deny list
- <project>/CLAUDE.md         — per-project instructions
- <project>/.claude/          — per-project conventions

I want you to:

1. ANALYZE how [TARGET TOOL] loads context — what files it reads, what directories 
   it watches, how its memory or instruction system works. If you're not certain, 
   ask me to check the tool's settings or documentation before proceeding.

2. MAP each Claude Code concept to its equivalent in [TARGET TOOL]:
   - CLAUDE.md → what file does [TARGET TOOL] use for persistent instructions?
   - rules/ → does it support modular rule files or one big file?
   - skills/ → can it load on-demand knowledge, or do we flatten everything?
   - commands/ → does it have slash commands, prompts, or workflow templates?
   - settings.json denyCommands → can these be enforced or only instructed?
   - Hooks (PreToolUse, PostToolUse) → any equivalent lifecycle system?
   - .mcp.json → does it support MCP? Same format?

3. GENERATE a sync script (sync-[toolname].sh) that:
   - Syncs global conventions from ~/.claude/ to [TARGET TOOL]'s global config
   - Syncs per-project conventions from .claude/ to [TARGET TOOL]'s project config
   - Handles skills correctly (direct copy if supported, merged index if not)
   - Extracts the deny list as plain-language instructions if not enforceable
   - Is idempotent (safe to run multiple times)
   - Place it at: ~/.claude/sync/sync-[toolname].sh

4. AUTOMATE it so I never have to think about it:
   - A file watcher that triggers on any change to .claude/ or CLAUDE.md
   - A background daemon (LaunchAgent for macOS, systemd for Linux)
   - A shell hook so syncing fires automatically when I cd into any project
   - Three aliases: csync-[tool], csync-[tool]-here, csync-[tool]-log

5. TELL ME about anything that cannot be automated — things I need to configure 
   manually once in [TARGET TOOL]'s settings or UI.

My operating system is [macOS / Linux / Windows].
My shell is [zsh / bash].
My projects are in: [list your project directories, e.g. ~/Projects, ~/Code]

Start by confirming your understanding of [TARGET TOOL]'s convention system, 
then proceed through each step.
```

---

## How to use this prompt

**Fill in the placeholders:**
- `[TARGET TOOL]` — the IDE or LLM tool you want to bridge (e.g. Cursor, Codex, Windsurf)
- `[macOS / Linux / Windows]` — your operating system
- `[zsh / bash]` — your shell
- `[list your project directories]` — where your code lives

**Example filled prompt:**
```
I use Claude Code as my primary agentic coding environment and want to keep its
convention system as my single source of truth. I now want to bridge these
conventions to Cursor.

[...rest of prompt...]

My operating system is macOS.
My shell is zsh.
My projects are in: ~/Projects, ~/Code
```

**If Claude doesn't know the target tool well,** add this at the end:
```
I'm attaching [TOOL]'s documentation for how it loads context:
[paste or link the relevant docs]
```

---

## What you'll get back

1. **Convention mapping table** — every Claude Code concept mapped to its equivalent
2. **`sync-[toolname].sh`** — the sync script
3. **Watcher script** — `watch-[toolname].sh`
4. **Daemon config** — LaunchAgent plist or systemd service file
5. **Shell hook + aliases** — snippet to add to `.zshrc` or `.bashrc`
6. **Manual steps** — anything that can't be automated (usually just MCP setup)

---

## Already bridged tools

These tools already have pre-built mappings. You can use a shorter prompt:

| Tool | Short prompt |
|------|-------------|
| Antigravity | Already set up with full automation |
| Cursor | `Bridge my Claude Code conventions to Cursor. macOS, zsh, projects in ~/Projects.` |
| Codex | `Bridge my Claude Code conventions to Codex (OpenAI). macOS, zsh.` |
| Windsurf | `Bridge my Claude Code conventions to Windsurf. macOS, zsh.` |
| GitHub Copilot | `Bridge my Claude Code conventions to GitHub Copilot. macOS, zsh.` |
| Continue | `Bridge my Claude Code conventions to Continue. macOS, zsh.` |

For tools not in this list, use the full prompt above.

---

## After bridging a new tool

Once the sync is set up for a new tool, it helps to document the mapping so future
setups are faster. Ask Claude:

```
Save this mapping to ~/.claude/sync/known-mappings/[toolname].md 
so I (or anyone) can set this up again instantly in the future.
```

This builds up your personal library of tool mappings over time.
