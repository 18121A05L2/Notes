---
name: test
description: "Create clear, safe MacBook and macOS instructions for setup, troubleshooting, maintenance, developer tools, networking, privacy, and performance tasks."
argument-hint: "Describe the MacBook or macOS task, symptoms, macOS version, and whether commands may be run."
agent: agent
model:
  - "GPT-5 (copilot)"
  - "Claude Sonnet 4.5 (copilot)"
tools:
  - read
  - search
  - execute
  - web
---

# MacBook Instructions Prompt

Help me complete the following MacBook/macOS task:

> ${input:task:Describe the MacBook or macOS task}

Use this context when available:

- macOS version: ${input:macosVersion:Unknown}
- MacBook model or chip: ${input:macModel:Unknown}
- User goal or expected result: ${input:expectedResult:Unknown}
- May you run terminal commands: ${input:commandPermission:No, explain commands only}

## Instructions

1. Clarify the goal from the task and identify the smallest safe path to achieve it.
2. Check relevant repository instructions, existing scripts, and local configuration before recommending project-specific changes.
3. Prefer built-in macOS settings, Apple-supported tools, and project-local tools over installing new software.
4. Separate diagnosis, recommended action, and verification. Explain what each command changes before suggesting it.
5. Treat commands as read-only unless the user explicitly allows changes. Never run destructive commands, delete files, reset settings, modify security controls, or install software without explicit permission.
6. Protect privacy: do not request or expose passwords, API keys, recovery keys, tokens, personal data, or full sensitive command output.
7. Account for Apple Silicon versus Intel differences, current macOS permissions, FileVault, Gatekeeper, iCloud, network privacy, and external displays when relevant.
8. Include a rollback or undo step for every change that modifies system or project state.
9. If the task depends on current macOS behavior, a third-party tool, or changing documentation, use authoritative web sources and state the source date.
10. If the available information is insufficient, ask only the minimum targeted questions needed to avoid unsafe instructions.

## Required Response Format

### Diagnosis

State the likely cause or explain what is unknown. Do not present guesses as facts.

### Steps

Give numbered steps with exact menu paths or commands. Label each command as `read-only` or `changes state`.

### Verify

Give one or more checks that confirm the task succeeded.

### Undo

Explain how to reverse any state-changing step.

### Notes

Mention compatibility, security, privacy, or backup considerations only when relevant.

Keep the answer concise, concrete, and beginner-friendly. Do not use filler. If you recommend terminal commands, format them as a code block and explain the expected result.
