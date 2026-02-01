# Quickstart: Git Worktree Creation Script

**Feature**: 260201-is0r-worktree-create-script
**Date**: 2026-02-01

## Overview

`wt-create` is a standalone shell script that creates git worktrees with memorable random names, enabling parallel development with minimal friction.

## Installation

### Option 1: Symlink (recommended for development)

```bash
# From the byoman repository root
ln -s "$(pwd)/bin/wt-create" ~/.local/bin/wt-create
```

### Option 2: Copy to PATH

```bash
cp bin/wt-create ~/.local/bin/
chmod +x ~/.local/bin/wt-create
```

### Option 3: Direct invocation

```bash
/path/to/byoman/bin/wt-create
```

## Basic Usage

### Create an exploratory worktree

```bash
cd /path/to/your/repo
wt-create
```

This will:
1. Generate a random memorable name (e.g., "prague")
2. Create branch `wt/prague`
3. Create worktree at `/path/to/your/repo-worktrees/prague`
4. Present menu to open in your preferred tool

### Work on an existing branch

```bash
wt-create feature/login
```

Creates a worktree for the existing `feature/login` branch.

### Get help

```bash
wt-create help
```

## Workflow Example

```bash
# 1. You're working on main, but want to explore an idea
$ cd ~/code/myproject
$ wt-create
Created worktree: tokyo
Path: /Users/you/code/myproject-worktrees/tokyo
Branch: wt/tokyo

Open in:
  1) VSCode
  2) Cursor
  3) Ghostty
  0) Exit

Choice: 1

# 2. VSCode opens in the new worktree
# 3. You explore, prototype, experiment...
# 4. If the idea works out, use /speckit.specify to name it properly
#    (The specify command can rename wt/tokyo → 260201-xxxx-feature-name)
# 5. If not, just delete the worktree: git worktree remove tokyo
```

## Worktree Location

All worktrees are created as siblings to your main repository:

```
~/code/
├── myproject/              # Main repository
└── myproject-worktrees/    # All worktrees for myproject
    ├── prague/
    ├── tokyo/
    └── berlin/
```

## Requirements

- Git 2.5+ (for worktree support)
- Bash 3.2+ (for array support)
- macOS or Linux

## Supported Applications

The script automatically detects which applications are available:

**Editors**: VSCode, Cursor
**Terminals**: Ghostty, iTerm2, Terminal.app, GNOME Terminal, Konsole
**File Managers**: Finder, Nautilus, Dolphin

Only installed applications appear in the menu.
