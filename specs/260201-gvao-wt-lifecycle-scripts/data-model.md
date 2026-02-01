# Data Model: Worktree Lifecycle Scripts

**Date**: 2026-02-01 | **Plan**: [plan.md](plan.md)

## Overview

These scripts operate on git-managed entities without introducing new persistent storage. This document describes the conceptual data model and state machines for the entities involved.

## Entities

### 1. Worktree

A git worktree is an additional working tree linked to the main repository.

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| `path` | string | `git worktree list` | Absolute path to worktree directory |
| `name` | string | Derived from path | Last segment of path (e.g., "london") |
| `branch` | string | `git worktree list` | Branch checked out in worktree |
| `commit` | string | `git worktree list --porcelain` | Current HEAD commit SHA |
| `is_current` | boolean | Comparison with `pwd` | Whether user is inside this worktree |
| `has_uncommitted` | boolean | `git diff --quiet` | Has uncommitted changes |
| `has_untracked` | boolean | `git ls-files --others` | Has untracked files |

**State Machine**:
```
                    ┌──────────────────┐
                    │     Active       │
                    │  (worktree dir   │
                    │    exists)       │
                    └────────┬─────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│    Clean      │   │    Dirty      │   │   Detached    │
│ (no changes)  │   │ (uncommitted) │   │  (no branch)  │
└───────────────┘   └───────────────┘   └───────────────┘
        │                    │
        │   wt-delete        │   wt-delete (with stash/discard)
        ▼                    ▼
                    ┌───────────────┐
                    │    Deleted    │
                    │ (removed from │
                    │   git refs)   │
                    └───────────────┘
```

### 2. Branch

A git branch associated with a worktree, potentially linked to a PR.

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| `name` | string | `git branch` | Branch name (e.g., "wt/london") |
| `local_exists` | boolean | `git show-ref` | Branch exists locally |
| `remote_exists` | boolean | `git ls-remote` | Branch exists on origin |
| `has_unpushed` | boolean | `git log` comparison | Local commits not on remote |
| `is_merged` | boolean | `git branch --merged` | Merged into default branch |
| `pr_number` | int? | `gh pr view` | Associated PR number (if any) |

**State Machine**:
```
┌────────────────┐
│  Local Only    │ ─────────────┐
│ (not pushed)   │              │
└───────┬────────┘              │
        │ git push              │
        ▼                       │
┌────────────────┐              │
│  Local+Remote  │              │
│   (pushed)     │              │
└───────┬────────┘              │
        │ PR created            │
        ▼                       │
┌────────────────┐              │
│    With PR     │              │
│   (tracked)    │              │
└───────┬────────┘              │
        │ PR merged             │
        ▼                       │
┌────────────────┐              │
│    Merged      │◄─────────────┘
│  (into main)   │     (direct merge without PR)
└───────┬────────┘
        │ wt-delete (cleanup)
        ▼
┌────────────────┐
│    Deleted     │
│ (refs removed) │
└────────────────┘
```

### 3. Pull Request

A GitHub PR associated with a branch.

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| `number` | int | `gh pr view` | PR number |
| `url` | string | `gh pr view` | Web URL for PR |
| `state` | enum | `gh pr view` | OPEN, CLOSED, MERGED |
| `draft` | boolean | `gh pr view` | Is draft PR |
| `mergeable` | enum | `gh pr view` | MERGEABLE, CONFLICTING, UNKNOWN |
| `merge_state` | enum | `gh pr view` | CLEAN, DIRTY, UNSTABLE, BLOCKED |
| `review_decision` | enum | `gh pr view` | APPROVED, CHANGES_REQUESTED, REVIEW_REQUIRED |
| `checks_status` | object | `gh pr view` | Aggregated CI check results |

**State Machine**:
```
                    ┌───────────────┐
     wt-pr          │     None      │
    (create)        │  (no PR yet)  │
        │           └───────┬───────┘
        │                   │
        ▼                   │
┌───────────────┐           │
│     Draft     │           │
│ (work in      │           │
│  progress)    │           │
└───────┬───────┘           │
        │ Mark ready        │
        ▼                   │
┌───────────────┐           │
│     Open      │◄──────────┘
│  (ready for   │     wt-pr (create ready)
│   review)     │
└───────┬───────┘
        │
┌───────┴───────┐
│               │
▼               ▼
┌─────────┐   ┌─────────────┐
│ Merged  │   │   Closed    │
│ (done)  │   │ (abandoned) │
└─────────┘   └─────────────┘
```

## Relationships

```
┌──────────────┐       1:1        ┌──────────────┐
│   Worktree   │─────────────────▶│    Branch    │
│              │                  │              │
│  path        │                  │  name        │
│  name        │                  │  has_pr      │
│  has_changes │                  │  is_merged   │
└──────────────┘                  └──────┬───────┘
                                         │
                                         │ 0..1:1
                                         ▼
                                  ┌──────────────┐
                                  │ Pull Request │
                                  │              │
                                  │  number      │
                                  │  state       │
                                  │  mergeable   │
                                  └──────────────┘
```

- A **Worktree** has exactly one **Branch** checked out
- A **Branch** may have zero or one **Pull Request** (cannot have multiple open PRs for same branch)
- Deleting a **Worktree** doesn't automatically delete the **Branch** (user choice)
- Merging a **Pull Request** doesn't automatically delete the **Worktree** (user choice via `--delete-worktree`)

## Validation Rules

### Worktree Deletion

| Rule | Validation | User Resolution |
|------|------------|-----------------|
| Cannot delete non-existent worktree | Check `git worktree list` | Show available worktrees |
| Uncommitted changes present | Check `git diff --quiet` | Stash, discard, or abort |
| Unpushed commits present | Check `git log origin..HEAD` | Warn, require confirmation |

### PR Creation

| Rule | Validation | User Resolution |
|------|------------|-----------------|
| Must have commits to PR | Check `git log main..HEAD` | Show error with no changes |
| PR already exists | Check `gh pr view` | Show existing PR URL |
| Branch must be pushed | Check `git push --dry-run` | Auto-push before creating |

### PR Merge

| Rule | Validation | User Resolution |
|------|------------|-----------------|
| PR must exist | Check `gh pr view` | Offer to create PR first |
| Checks must pass | Check `statusCheckRollup` | Warn, allow override if permitted |
| Must be approved | Check `reviewDecision` | Warn, allow override if permitted |
| No merge conflicts | Check `mergeable` | Require conflict resolution |

## Exit Codes

Per `wt-create` contract and spec FR-033:

| Code | Meaning | When Used |
|------|---------|-----------|
| 0 | Success | Operation completed |
| 1 | General error | Unexpected failure |
| 2 | Invalid args | Bad command-line arguments |
| 3 | Git error | Git operation failed |
| 4 | Retry exhausted | (Not used in these scripts) |
