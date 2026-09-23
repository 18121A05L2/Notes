#!/bin/sh

set -eu

repository_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$repository_root"

formatter=""
if [ -x "node_modules/.bin/prettier" ]; then
    formatter="./node_modules/.bin/prettier"
elif command -v prettier >/dev/null 2>&1; then
    formatter="prettier"
else
    exit 0
fi

changed_files=$( {
    git diff --name-only --diff-filter=ACMR HEAD --
    git ls-files --others --exclude-standard
} | awk '
    /\.(css|html|js|jsx|json|md|scss|ts|tsx|yaml|yml)$/ && !seen[$0]++
')

[ -n "$changed_files" ] || exit 0

printf '%s\n' "$changed_files" | xargs "$formatter" --write