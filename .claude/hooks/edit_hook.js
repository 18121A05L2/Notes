/**
 * Claude Code Post-Tool Hook: README.md Restriction
 * 
 * This script checks if the completed tool operation involved modifying the main README.md.
 */

const forbiddenFile = /README\.md/i;
const toolArgs = process.env.CLAUDE_TOOL_ARGS || "";

if (forbiddenFile.test(toolArgs)) {
    console.warn("⚠️  WARNING: You have attempted to modify README.md. This file is restricted.");
    // Note: postToolUse runs AFTER the tool has completed. 
    // It can be used for verification, logging, or triggering follow-up actions.
}

process.exit(0);
