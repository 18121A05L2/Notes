/**
 * Claude Code Pre-Tool Hook: .env Restriction
 * 
 * This script intercepts file read requests and blocks them if they target .env files.
 */

const forbiddenPattern = /\.env($|\.)/i;
const toolArgs = process.env.CLAUDE_TOOL_ARGS || "";

// In a real Claude Code environment, tool arguments are often passed via environment variables
// or standard input. This script checks for .env mentions in the tool arguments.

if (forbiddenPattern.test(toolArgs)) {
    console.error("❌ SECURITY ALERT: Access to .env files is restricted by project policy.");
    process.exit(1); // Non-zero exit code stops the tool execution
}

process.exit(0); // Proceed with tool execution
