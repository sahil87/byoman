#!/bin/bash
# Master worktree setup script - runs all setup tasks in order

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$SCRIPT_DIR/worktree-setup"

if [ ! -d "$SETUP_DIR" ]; then
    echo "Error: Setup directory not found: $SETUP_DIR"
    exit 1
fi

echo "Running worktree setup tasks..."

for script in "$SETUP_DIR"/*.sh; do
    if [ -x "$script" ]; then
        echo ">>> Running $(basename "$script")..."
        "$script"
    fi
done

echo "Worktree setup complete."
