# Claude Code Alignment Skill

This skill ensures that Antigravity operates in strict accordance with the Claude Code standards defined in this repository.

## Instructions
Before executing any tool or providing research:
1.  **Read Permission Files**: check `/Users/lakshmi.sanikommu/Desktop/BlockChain/Notes/.claude/settings.json` and `managed-settings.json`.
2.  **Verify Commands**: If a command is blocked or not pre-approved in an `enterprise` setting, DO NOT execute it.
3.  **Load Skills**: check `/Users/lakshmi.sanikommu/Desktop/BlockChain/Notes/.claude/skills/` for relevant instructions.

## Priority
Enterprise Settings > Project Settings > User Request.

## Error Handling
If a tool use is blocked by Claude settings, inform the user: "This action is restricted by the project's Claude Code configuration in `.claude/settings.json`."
