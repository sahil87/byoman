# Research: Consolidate bin/ into .specify/

**Feature**: 260201-gofw-consolidate-bin-specify
**Date**: 2026-02-01

## Research Questions

### Q1: What internal path references exist in the scripts?

**Finding**: Only one hardcoded sibling reference exists:

| Script | Line | Reference | Context |
|--------|------|-----------|---------|
| wt-create | 621 | `$wt_path/bin/wt-setup` | Calls wt-setup in newly created worktree |

**Decision**: Update to `$wt_path/.specify/bin/wt-setup`

**Rationale**: This reference looks for wt-setup in the worktree being created, not the current script's location. After consolidation, new worktrees will have scripts at `.specify/bin/`.

**Alternatives considered**:
- Make wt-setup path configurable via environment variable - rejected as over-engineering for single use case
- Use `$SCRIPT_DIR` relative path - rejected as wt-create needs to find wt-setup in *target* worktree, not source

### Q2: How do scripts find each other?

**Finding**: Scripts use `SCRIPT_DIR` pattern for relative paths:

```bash
# wt-setup uses this pattern
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$SCRIPT_DIR/worktree-setup"
```

**Decision**: This pattern works regardless of absolute location. No changes needed.

**Rationale**: The `SCRIPT_DIR` pattern resolves to wherever the script is actually located. Moving from `bin/` to `.specify/bin/` doesn't break this.

### Q3: What documentation actively invokes scripts?

**Finding**: One active invocation path:

| File | Purpose | Status |
|------|---------|--------|
| `.claude/commands/speckit.build.md` | Invokes `bin/speckit-build` | **MUST UPDATE** |

**Decision**: Update path to `.specify/bin/speckit-build`

**Rationale**: This is the command definition that Claude uses. Other markdown files are historical documentation of past features.

### Q4: Should historical documentation be updated?

**Finding**: Multiple spec files reference `bin/` in their tasks.md and plan.md files:
- `specs/260201-gvao-wt-lifecycle-scripts/tasks.md` - 50+ references
- `specs/260201-is0r-worktree-create-script/tasks.md` - 30+ references
- `specs/260201-is0r-worktree-create-script/quickstart.md` - installation instructions

**Decision**: Do NOT update historical spec documentation

**Rationale**:
1. These describe the implementation *at the time it was done*
2. Updating them would falsify the historical record
3. They're not active invocation paths
4. Tasks are completed (marked with [X])

**Exception**: `quickstart.md` files in active specs that users might reference for installation should be updated or marked as superseded.

### Q5: What permissions must be preserved?

**Finding**: All scripts have executable permissions (`-rwxr-xr-x`):

```
-rwxr-xr-x speckit-build
-rwxr-xr-x wt-create
-rwxr-xr-x wt-delete
-rwxr-xr-x wt-merge
-rwxr-xr-x wt-pr
-rwxr-xr-x wt-setup
-rwxr-xr-x worktree-setup/1-setup-claude-permissions.sh
```

**Decision**: Use `git mv` to preserve permissions and history

**Rationale**: `git mv` preserves file permissions and maintains git history for proper blame/log tracking.

### Q6: What is the target structure within .specify/?

**Finding**: Current .specify structure:
- `scripts/bash/` - internal speckit scripts (8 files)
- `templates/` - command/spec templates
- `memory/` - constitution and state

**Decision**: Create `.specify/bin/` as a peer directory

**Rationale**:
- `scripts/` contains internal machinery not meant for direct user invocation
- `bin/` contains user-facing CLI tools meant to be added to PATH
- Clear semantic distinction: `scripts/` = internal, `bin/` = user interface

## Summary of Decisions

| Area | Decision |
|------|----------|
| Target location | `.specify/bin/` |
| Move method | `git mv` (preserve history + permissions) |
| Script updates | Update wt-create line 621 only |
| Doc updates | Update `.claude/commands/speckit.build.md` only |
| Historical docs | Leave unchanged |
| Directory removal | Automatic via `git mv` (empty bin/ removed) |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Missed internal reference | Low | Medium | Grep for `bin/` patterns before completing |
| Broken worktree setup | Medium | High | Test in actual worktree after move |
| Claude command fails | Low | High | Test `/speckit.build` after path update |
| External users have PATH to bin/ | Medium | Low | Breaking change is acceptable per spec assumptions |
