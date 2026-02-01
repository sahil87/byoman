#!/bin/bash
# Setup Claude Code permissions for worktree

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p .claude
cp "$SCRIPT_DIR/templates/settings.local.json" .claude/settings.local.json

echo "Created .claude/settings.local.json with permissions"
