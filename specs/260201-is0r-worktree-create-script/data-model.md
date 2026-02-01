# Data Model: Git Worktree Creation Script

**Feature**: 260201-is0r-worktree-create-script
**Date**: 2026-02-01

## Overview

This is a stateless shell script - no persistent data model. This document defines the conceptual entities and their relationships as handled during script execution.

## Entities

### Worktree

A git worktree created and managed by the script.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Memorable random name (e.g., "prague", "tokyo") |
| path | string | Absolute path to worktree directory |
| branch | string | Git branch checked out in this worktree |
| created_at | timestamp | When worktree was created (git metadata) |

**Constraints**:
- name: lowercase, alphanumeric, from predefined city list
- path: `<repo-parent>/<repo-name>-worktrees/<name>`
- branch: valid git branch name

### Repository Context

Information about the git repository where the script is run.

| Field | Type | Description |
|-------|------|-------------|
| root | string | Absolute path to repository root |
| name | string | Repository directory name |
| default_branch | string | main or master (auto-detected) |
| worktrees_dir | string | Path to worktrees sibling directory |

**Derivation**:
- root: `git rev-parse --show-toplevel`
- name: `basename "$root"`
- worktrees_dir: `dirname "$root"`/`<name>-worktrees`

### Available Application

A tool that can open the worktree directory.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Display name (e.g., "VSCode", "Cursor") |
| cli_cmd | string | CLI command to run (e.g., "code", "cursor") |
| bundle_id | string | macOS bundle identifier for mdfind |
| desktop_file | string | Linux .desktop filename |
| open_cmd | function | Platform-specific open command |
| available | boolean | Whether detected on current system |

**Supported Applications** (per FR-018):

| name | cli_cmd | bundle_id | desktop_file |
|------|---------|-----------|--------------|
| VSCode | code | com.microsoft.VSCode | code.desktop |
| Cursor | cursor | com.todesktop.230313mzl4w4u92 | cursor.desktop |
| Ghostty | ghostty | com.mitchellh.ghostty | com.mitchellh.ghostty.desktop |
| iTerm2 | - | com.googlecode.iterm2 | - |
| Terminal.app | - | com.apple.Terminal | - |
| GNOME Terminal | gnome-terminal | - | org.gnome.Terminal.desktop |
| Konsole | konsole | - | org.kde.konsole.desktop |
| Finder | - | com.apple.finder | - |
| Nautilus | nautilus | - | org.gnome.Nautilus.desktop |
| Dolphin | dolphin | - | org.kde.dolphin.desktop |

## State Transitions

### Worktree Creation Flow

```
[Start]
    │
    ▼
[Validate Git Repository]
    │ error: not a git repo
    ▼
[Determine Branch Mode]
    ├─ no arg → [Generate Random Name] → branch = wt/<name>
    └─ arg given → [Check Branch Exists]
                      ├─ local exists → use existing
                      ├─ remote exists → fetch & track
                      └─ not found → create new from default
    │
    ▼
[Check Name Collision]
    ├─ collision → [Retry with New Name] (up to N times)
    └─ no collision → continue
    │
    ▼
[Create Worktree Directory]
    │ error: permission denied
    ▼
[Run git worktree add]
    │ error: git error
    ▼
[Display Success + Path]
    │
    ▼
[Show Open Menu]
    │
    ▼
[Handle User Selection]
    │
    ▼
[End]
```

## Validation Rules

### Branch Name Validation

- Must be valid git branch name
- No control characters
- No `..` or `~` sequences
- Sanitized for directory creation (replace `/` with `-`)

### Worktree Name Validation

- Must be from predefined city list (when auto-generated)
- Lowercase alphanumeric only
- Must not already exist in worktrees directory

## Relationships

```
Repository 1:N Worktree
    - A repository can have multiple worktrees
    - Each worktree belongs to exactly one repository

Worktree 1:1 Branch
    - Each worktree checks out exactly one branch
    - A branch can only be checked out in one worktree at a time (git constraint)
```

## No Persistence

This script does not maintain any persistent storage:
- Git manages worktree metadata in `.git/worktrees/`
- No configuration files required (could add `~/.wt-create.conf` in future)
- No database or state files
