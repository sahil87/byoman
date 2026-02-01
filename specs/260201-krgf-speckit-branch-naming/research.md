# Research: Speckit Branch Naming Integration

**Feature**: 260201-krgf-speckit-branch-naming
**Date**: 2026-02-01
**Status**: Complete

## R1: Git Branch Renaming Approach

**Decision**: Use `git branch -m <old> <new>` for atomic rename

**Rationale**:
- Native git command, no dependencies
- Handles uncommitted changes safely (git branch -m is just a ref update)
- Works in worktrees (unlike some git operations that require main worktree)
- Single atomic operation - either succeeds fully or fails completely

**Alternatives considered**:
1. `git checkout -b <new> && git branch -d <old>` - Two operations, not atomic, loses tracking
2. Direct ref manipulation - Too low-level, no benefit over `git branch -m`

## R2: Temporary Branch Detection

**Decision**: Match branches starting with `wt/` prefix

**Rationale**:
- `wt-create` exclusively uses `wt/{city}` pattern for temporary branches
- Simple pattern match: `[[ "$branch" == wt/* ]]`
- No false positives expected (users don't manually create wt/* branches)
- Consistent with existing codebase convention

**Alternatives considered**:
1. Maintain list of "known temp branches" - Unnecessary complexity, wt/ prefix is sufficient
2. Check worktree metadata for temp flag - Not available in git worktree data

## R3: Branch Name Sanitization

**Decision**: Reuse and extend `clean_spec_name()` from common.sh

**Rationale**:
- Spec names already follow git-compatible naming (YYMMDD-XXXX-slug format)
- For `--branch` custom names: apply same sanitization (lowercase, replace spaces with hyphens, remove invalid chars)
- Invalid git branch characters: `~`, `^`, `:`, `?`, `*`, `[`, `\`, spaces, control chars

**Sanitization rules**:
```bash
# Convert to lowercase
# Replace spaces with hyphens
# Remove chars: ~ ^ : ? * [ \ and ASCII control chars
# Collapse multiple hyphens to single
# Trim leading/trailing hyphens
```

**Alternatives considered**:
1. Reject invalid names with error - Poor UX, users expect automatic cleanup
2. No sanitization for --branch flag - Risk of git errors with user-provided names

## R4: Local Branch Collision Handling

**Decision**: Auto-append numeric suffix (`-2`, `-3`, etc.) without prompting

**Rationale**:
- Matches user expectation from spec (FR-008)
- Non-interactive operation is important for scripted workflows
- Maximum suffix attempts: 10 (same as wt-create retry pattern)
- User is informed of adjusted name in output

**Algorithm**:
```bash
target="branch-name"
if branch_exists_locally "$target"; then
    for i in {2..11}; do
        candidate="${target}-${i}"
        if ! branch_exists_locally "$candidate"; then
            target="$candidate"
            break
        fi
    done
fi
```

**Alternatives considered**:
1. Prompt user for new name - Breaks non-interactive use
2. Fail with error - Poor UX when user just wants it to work
3. Overwrite existing - Dangerous data loss

## R5: Remote Branch Collision Handling

**Decision**: Warn but proceed for auto-generated names; skip check for `--branch` flag

**Rationale**:
- Auto-generated names: user didn't choose the name, so a warning helps
- User-provided `--branch`: user is explicitly choosing, assume they know what they're doing
- Remote collision isn't blocking - user may intentionally continue work on existing remote branch
- Performance: skip unnecessary network call for `--branch` flag

**Remote check command**:
```bash
git ls-remote --heads origin "$branch" 2>/dev/null | grep -q "$branch"
```

**Alternatives considered**:
1. Always check remote - Unnecessary latency for explicit --branch flag
2. Never check remote - Misses opportunity to warn about unexpected collision
3. Block on remote collision - Too restrictive, breaks legitimate use case

## R6: Push and Tracking Prompt

**Decision**: Prompt user after successful rename; skip if no remote configured

**Rationale**:
- Some users want immediate push, others prefer to push later
- Pushing sets up tracking automatically with `-u` flag
- Detect remote existence with `git remote | grep -q origin`
- Non-interactive mode (`--json`) should skip prompt and not push

**Prompt flow**:
```
✓ Renamed branch: wt/amsterdam → 260201-krgf-speckit-branch-naming
Push to origin and set up tracking? [y/N]
```

**Alternatives considered**:
1. Always push - May conflict with user workflow
2. Never push - Users must remember extra step
3. Add --push flag - Adds complexity; prompt is simpler

## R7: Error Recovery Strategy

**Decision**: Spec creation succeeds even if branch rename fails (FR-009)

**Rationale**:
- Primary value is the spec itself, not the branch name
- Branch rename is enhancement, not critical path
- User can manually rename later if needed
- Clear error message explains what failed and why

**Error output format** (Constitution III compliant):
```
Warning: Branch rename failed
  Why: Target branch '260201-krgf-feature' already exists (local and suffixed variants exhausted)
  Spec created successfully. You can rename the branch manually with:
    git branch -m wt/amsterdam 260201-krgf-feature-custom
```

**Alternatives considered**:
1. Fail entire operation - Too disruptive for non-critical enhancement
2. Silent failure - Violates Constitution III (no silent failures)

## R8: Integration Point in create-new-feature.sh

**Decision**: Call `rename-branch.sh` after spec creation, before JSON output

**Rationale**:
- Spec must exist before rename (need spec name)
- JSON output should include final branch name
- Separate script for single-responsibility (Constitution III)

**Integration location** (around line 204 of create-new-feature.sh):
```bash
set_current_spec "$SPEC_NAME"

# NEW: Branch rename hook
if [[ "$RENAME_BRANCH" == "true" ]]; then
    BRANCH_RESULT=$(rename-branch.sh --target "$SPEC_NAME" ${CUSTOM_BRANCH:+--branch "$CUSTOM_BRANCH"})
    # Parse result for JSON output
fi

# Existing JSON output (modified to include branch info)
```

**Alternatives considered**:
1. Inline in create-new-feature.sh - Violates single-responsibility, file becomes too long
2. Post-execution hook in speckit.specify.md - Less reliable, duplicates logic

## Unresolved Items

None - all NEEDS CLARIFICATION items from Technical Context have been resolved through this research.
