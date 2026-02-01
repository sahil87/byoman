# Data Model: Speckit Branch Naming Integration

**Feature**: 260201-krgf-speckit-branch-naming
**Date**: 2026-02-01

## Entities

### Branch

Represents a git branch in the worktree.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Branch name (e.g., `wt/amsterdam`, `260201-krgf-feature`) |
| type | enum | `temporary` (matches `wt/*`) or `canonical` (any other pattern) |
| exists_locally | boolean | Whether branch exists in local refs |
| exists_remotely | boolean | Whether branch exists on origin remote |
| has_tracking | boolean | Whether local branch tracks a remote branch |

**Validation rules**:
- Name must not contain: `~`, `^`, `:`, `?`, `*`, `[`, `\`, spaces, or control characters
- Name must not start or end with `/` or `.`
- Name must not be empty

**State transitions**:
```
[temporary] --rename--> [canonical]
[canonical] --preserve--> [canonical] (no change unless --branch flag)
[canonical] --rename--> [canonical] (only with explicit --branch flag)
```

### RenameOperation

Represents a branch rename request and its outcome.

| Field | Type | Description |
|-------|------|-------------|
| source | string | Original branch name |
| target | string | Desired new branch name |
| final_target | string | Actual target name (may differ if collision occurred) |
| status | enum | `success`, `skipped`, `failed` |
| reason | string | Human-readable explanation of outcome |
| collision_type | enum? | `none`, `local`, `remote`, `both` (only if status != success) |

**Status reasons**:
- `success`: "Renamed branch: {source} → {final_target}"
- `skipped`: "Branch is already canonical: {source}"
- `skipped`: "On protected branch (main/master), no rename performed"
- `failed`: "Target branch exists locally and all suffixed variants exhausted"

### SpecContext

Context from the spec creation that drives branch naming.

| Field | Type | Description |
|-------|------|-------------|
| spec_name | string | Generated spec name (e.g., `260201-krgf-speckit-branch-naming`) |
| custom_branch | string? | User-provided branch name via `--branch` flag (optional) |
| rename_enabled | boolean | Whether branch rename should be attempted (default: true) |

## Relationships

```
SpecContext 1--1 RenameOperation : triggers
RenameOperation 1--1 Branch (source) : renames from
RenameOperation 1--1 Branch (target) : renames to
```

## State Machine: Rename Flow

```
                    ┌─────────────────┐
                    │  Start          │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Get current     │
                    │ branch name     │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
        ┌─────▼─────┐  ┌─────▼─────┐  ┌─────▼─────┐
        │ wt/*      │  │ main/     │  │ other     │
        │ (temp)    │  │ master    │  │ (canonical)│
        └─────┬─────┘  └─────┬─────┘  └─────┬─────┘
              │              │              │
              │         ┌────▼────┐    ┌────▼────┐
              │         │ Warn    │    │ --branch│
              │         │ only    │    │ flag?   │
              │         └────┬────┘    └────┬────┘
              │              │         no   │   yes
              │              │    ┌────┴────┴────┐
              │              │    │              │
        ┌─────▼─────────────┬┴────▼─────┐  ┌────▼────┐
        │ Compute target    │  SKIP     │  │ Use     │
        │ (spec_name or     │  (return) │  │ --branch│
        │ --branch value)   │           │  │ value   │
        └─────┬─────────────┘           │  └────┬────┘
              │                         │       │
        ┌─────▼─────┐                   │       │
        │ Sanitize  │◄──────────────────┴───────┘
        │ target    │
        └─────┬─────┘
              │
        ┌─────▼─────┐
        │ Check     │
        │ local     │
        │ collision │
        └─────┬─────┘
              │
       exists │      not exists
     ┌────────┴────────┐
     │                 │
┌────▼────┐      ┌─────▼─────┐
│ Add     │      │ Check     │
│ suffix  │      │ remote    │
│ -2..-11 │      │ collision │
└────┬────┘      └─────┬─────┘
     │                 │
     │ success    exists│      not exists
     │           ┌──────┴──────┐
     │           │             │
     │     ┌─────▼─────┐ ┌─────▼─────┐
     │     │ Warn      │ │ Proceed   │
     │     │ (remote   │ │           │
     │     │ exists)   │ │           │
     │     └─────┬─────┘ └─────┬─────┘
     │           │             │
     └───────────┴──────┬──────┘
                        │
                 ┌──────▼──────┐
                 │ git branch  │
                 │ -m old new  │
                 └──────┬──────┘
                        │
                 success│      failure
              ┌─────────┴─────────┐
              │                   │
        ┌─────▼─────┐       ┌─────▼─────┐
        │ Prompt    │       │ Return    │
        │ push?     │       │ failure   │
        │ (if       │       │ (spec     │
        │ remote    │       │ still     │
        │ exists)   │       │ created)  │
        └─────┬─────┘       └───────────┘
              │
        ┌─────▼─────┐
        │ SUCCESS   │
        │ (return   │
        │ new name) │
        └───────────┘
```

## Exit Codes

Following POSIX conventions and existing `wt-create` patterns:

| Code | Constant | Meaning |
|------|----------|---------|
| 0 | EXIT_SUCCESS | Rename successful or correctly skipped |
| 1 | EXIT_GENERAL_ERROR | Unexpected failure |
| 3 | EXIT_GIT_ERROR | Git command failed |
| 4 | EXIT_RETRY_EXHAUSTED | All collision suffixes exhausted |

Note: These codes are internal to `rename-branch.sh`. The parent `create-new-feature.sh` always succeeds if spec was created, regardless of rename outcome (per FR-009).
