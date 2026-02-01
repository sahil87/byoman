# Contract: bin/ to .specify/bin/ Relocation

**Feature**: 260201-gofw-consolidate-bin-specify
**Date**: 2026-02-01

## Pre-conditions

Before relocation begins, the following MUST be true:

| ID | Condition | Verification |
|----|-----------|--------------|
| PRE-001 | `bin/` directory exists at repo root | `[ -d bin ]` |
| PRE-002 | `bin/` contains exactly 6 scripts + 1 subdirectory | `ls bin/ \| wc -l` = 7 |
| PRE-003 | `.specify/` directory exists | `[ -d .specify ]` |
| PRE-004 | `.specify/bin/` does NOT exist | `[ ! -d .specify/bin ]` |
| PRE-005 | Working directory is clean (no uncommitted changes) | `git diff --quiet` |

## Post-conditions

After relocation completes, the following MUST be true:

| ID | Condition | Verification |
|----|-----------|--------------|
| POST-001 | `bin/` directory does NOT exist at repo root | `[ ! -d bin ]` |
| POST-002 | `.specify/bin/` contains exactly 6 scripts + 1 subdirectory | `ls .specify/bin/ \| wc -l` = 7 |
| POST-003 | All scripts are executable | `[ -x .specify/bin/wt-create ]` etc. |
| POST-004 | wt-create references updated path | `grep -q '.specify/bin/wt-setup' .specify/bin/wt-create` |
| POST-005 | speckit.build.md references updated path | `grep -q '.specify/bin/speckit-build' .claude/commands/speckit.build.md` |
| POST-006 | Git history preserved for all files | `git log --follow .specify/bin/wt-create` shows history |

## Script Behavior Contract

Each script MUST maintain identical behavior before and after relocation:

### speckit-build

| Input | Expected Output |
|-------|-----------------|
| `help` | Usage documentation |
| `--dry-run` | Execution plan without running |
| `<valid-spec>` | Build pipeline execution |

### wt-create

| Input | Expected Output |
|-------|-----------------|
| (no args) | Random name worktree creation |
| `<branch-name>` | Named branch worktree creation |
| `help` | Usage documentation |

### wt-delete

| Input | Expected Output |
|-------|-----------------|
| (no args, in worktree) | Delete current worktree prompt |
| `<name>` | Delete named worktree prompt |
| `--list` | List all worktrees |
| `help` | Usage documentation |

### wt-pr

| Input | Expected Output |
|-------|-----------------|
| (no args) | PR creation menu |
| `--draft` | Create draft PR |
| `help` | Usage documentation |

### wt-merge

| Input | Expected Output |
|-------|-----------------|
| (no args) | Merge current PR prompt |
| `--force` | Merge despite failing checks |
| `help` | Usage documentation |

### wt-setup

| Input | Expected Output |
|-------|-----------------|
| (no args) | Run all setup tasks |

## Error Handling

| Scenario | Expected Behavior |
|----------|-------------------|
| PRE-004 violated (.specify/bin exists) | Abort with error message |
| git mv fails | Abort with error, no partial state |
| Missing script after move | Rollback all moves, restore bin/ |

## Exit Codes

All scripts maintain their existing exit code contracts:

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Invalid arguments |
| 3 | Git operation error |
| 4 | Retry exhausted (wt-create only) |
