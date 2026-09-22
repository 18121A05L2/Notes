---
name: Tool Lifecycle Safety
description: "Use when configuring pre-tool or post-tool behavior, Claude hooks, VS Code hooks, file safety, .env protection, README changes, or agent lifecycle automation."
---

# Tool Lifecycle Safety

Follow these checks around every tool operation.

## Pre-Tool Checks

Before reading or modifying a file:

- Never read `.env`, `.env.*`, credentials, private keys, tokens, or secret files unless explicitly authorized.
- If a requested path matches `.env` or another secret pattern, stop and explain that access is restricted.
- Inspect repository instructions before making changes.
- Confirm the target file and the smallest required scope.
- Do not run destructive commands, reset history, delete files, or install dependencies without explicit authorization.

## Post-Tool Checks

After any write or edit:

- Check whether `README.md` was modified.
- If `README.md` was changed, warn the user and explain what was changed.
- Run the narrowest relevant validation available.
- Check for formatting, syntax, type, lint, or test failures.
- Report the files changed and validation performed.

## Claude Hook Compatibility

The executable source of truth is:

- `.claude/hooks/read_hook.js`
- `.claude/hooks/edit_hook.js`
- `.claude/settings.json`

These scripts may enforce behavior automatically in Claude Code. This instruction mirrors their behavior for GitHub Copilot, but `.instructions.md` files are guidance and do not execute shell commands by themselves.

For automatic VS Code enforcement, configure equivalent hooks in a custom agent's `hooks` frontmatter or a supported `.github/hooks` configuration.