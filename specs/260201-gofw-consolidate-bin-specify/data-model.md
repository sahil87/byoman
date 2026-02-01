# Data Model: Consolidate bin/ into .specify/

**Feature**: 260201-gofw-consolidate-bin-specify
**Date**: 2026-02-01

## Entity: File Mapping

Since this feature involves file reorganization rather than data structures, the "data model" represents the file mapping from old to new locations.

### File Relocation Map

| Old Path | New Path | Type |
|----------|----------|------|
| `bin/speckit-build` | `.specify/bin/speckit-build` | executable script |
| `bin/wt-create` | `.specify/bin/wt-create` | executable script |
| `bin/wt-delete` | `.specify/bin/wt-delete` | executable script |
| `bin/wt-merge` | `.specify/bin/wt-merge` | executable script |
| `bin/wt-pr` | `.specify/bin/wt-pr` | executable script |
| `bin/wt-setup` | `.specify/bin/wt-setup` | executable script |
| `bin/worktree-setup/` | `.specify/bin/worktree-setup/` | directory |
| `bin/worktree-setup/1-setup-claude-permissions.sh` | `.specify/bin/worktree-setup/1-setup-claude-permissions.sh` | executable script |
| `bin/worktree-setup/templates/` | `.specify/bin/worktree-setup/templates/` | directory |
| `bin/worktree-setup/templates/settings.local.json` | `.specify/bin/worktree-setup/templates/settings.local.json` | config template |

### Entity: Reference Update

Internal script references that require modification:

| Entity | Field | Old Value | New Value |
|--------|-------|-----------|-----------|
| wt-create:621 | setup_script | `$wt_path/bin/wt-setup` | `$wt_path/.specify/bin/wt-setup` |
| speckit.build.md:20 | invocation | `bin/speckit-build` | `.specify/bin/speckit-build` |

### Validation Rules

1. **Executable Permission**: All `.sh` files and scripts without extension MUST have mode `755` (rwxr-xr-x)
2. **Git History**: All moves MUST be performed via `git mv` to preserve commit history
3. **Completeness**: Old `bin/` directory MUST be empty and removed after relocation
4. **Functionality**: All scripts MUST execute identically from new location

### State Transitions

```
bin/ exists → git mv operations → bin/ empty → bin/ removed → .specify/bin/ complete
```

| State | Condition | Valid Transitions |
|-------|-----------|-------------------|
| `bin_exists` | bin/ contains scripts | → `moving` |
| `moving` | git mv in progress | → `bin_empty` or → `error` |
| `bin_empty` | bin/ is empty directory | → `bin_removed` |
| `bin_removed` | bin/ no longer exists | → `complete` |
| `complete` | All scripts in .specify/bin/ | Terminal state |
| `error` | Move operation failed | → `rollback` → `bin_exists` |

## Directory Structure Invariants

### Before (MUST exist)
```
bin/
├── speckit-build
├── wt-create
├── wt-delete
├── wt-merge
├── wt-pr
├── wt-setup
└── worktree-setup/
    ├── 1-setup-claude-permissions.sh
    └── templates/
        └── settings.local.json
```

### After (MUST exist)
```
.specify/bin/
├── speckit-build
├── wt-create
├── wt-delete
├── wt-merge
├── wt-pr
├── wt-setup
└── worktree-setup/
    ├── 1-setup-claude-permissions.sh
    └── templates/
        └── settings.local.json
```

### After (MUST NOT exist)
```
bin/  ← This directory must be removed
```
