# Quickstart: Script Location Change

**Feature**: 260201-gofw-consolidate-bin-specify
**Date**: 2026-02-01

## What Changed

Project scripts have moved from `bin/` to `.specify/bin/` to keep the root directory clean.

## Updated Paths

| Script | Old Path | New Path |
|--------|----------|----------|
| speckit-build | `bin/speckit-build` | `.specify/bin/speckit-build` |
| wt-create | `bin/wt-create` | `.specify/bin/wt-create` |
| wt-delete | `bin/wt-delete` | `.specify/bin/wt-delete` |
| wt-merge | `bin/wt-merge` | `.specify/bin/wt-merge` |
| wt-pr | `bin/wt-pr` | `.specify/bin/wt-pr` |
| wt-setup | `bin/wt-setup` | `.specify/bin/wt-setup` |

## If You Had bin/ in Your PATH

Update your shell configuration:

```bash
# Old (remove this)
export PATH="$PATH:/path/to/byoman/bin"

# New (add this)
export PATH="$PATH:/path/to/byoman/.specify/bin"
```

## If You Symlinked Scripts

Update your symlinks:

```bash
# Remove old symlinks
rm ~/.local/bin/wt-create ~/.local/bin/wt-delete ~/.local/bin/wt-merge ~/.local/bin/wt-pr

# Create new symlinks
ln -sf "$(pwd)/.specify/bin/wt-create" ~/.local/bin/wt-create
ln -sf "$(pwd)/.specify/bin/wt-delete" ~/.local/bin/wt-delete
ln -sf "$(pwd)/.specify/bin/wt-merge" ~/.local/bin/wt-merge
ln -sf "$(pwd)/.specify/bin/wt-pr" ~/.local/bin/wt-pr
```

## Verify Installation

```bash
# Check scripts are executable
.specify/bin/wt-create help
.specify/bin/speckit-build help

# If in PATH
wt-create help
```

## No Changes Needed

- Script behavior is unchanged
- Script options and arguments are unchanged
- Output format is unchanged
- Exit codes are unchanged
