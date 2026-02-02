# Data Model: Byobu Tab Option for wt-create

**Feature**: 260202-4act-byobu-tab-option
**Date**: 2026-02-02

## Overview

This feature does not introduce persistent data. It uses transient runtime values derived from the git repository and byobu session context.

## Entities

### Worktree Context (transient)

- **repo_name**: Short name of the repository
- **worktree_name**: Name of the created worktree
- **worktree_path**: Absolute path to the created worktree
- **branch_name**: Branch associated with the worktree

### Byobu Session Context (transient)

- **session_active**: Boolean indicating an active byobu session
- **tab_name**: Derived display name using `repo_name + worktree_name`
- **tab_focus**: Boolean indicating the tab should be focused after creation

## Validation Rules

- Worktree context must exist only after successful worktree creation.
- Byobu session context must be present to expose the byobu tab option.
- Tab name must be derived from repo name plus worktree name.
