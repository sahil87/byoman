# Implementation Plan: Speckit Branch Naming Integration

**Branch**: `260201-krgf-speckit-branch-naming` | **Date**: 2026-02-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/260201-krgf-speckit-branch-naming/spec.md`

## Summary

Add automatic branch renaming to speckit.specify so that temporary worktree branches (`wt/*` pattern) are renamed to match the spec name (e.g., `260201-krgf-speckit-branch-naming`). This integrates with the existing `create-new-feature.sh` script by adding a post-creation hook that detects temporary branches, sanitizes/validates the target name, handles collisions, and optionally pushes to remote.

## Technical Context

**Language/Version**: Bash (POSIX-compliant, tested with bash 3.2+ and 5+)
**Primary Dependencies**: git (branch operations, remote checks), standard POSIX utilities
**Storage**: N/A (git manages all branch state)
**Testing**: Manual integration tests via bash; existing pattern has no automated test framework for scripts
**Target Platform**: Unix-like systems (macOS, Linux)
**Project Type**: CLI scripts (single project)
**Performance Goals**: <100ms for branch operations (per Constitution IV)
**Constraints**: POSIX compliance, <50 line functions, <500 line files (per Constitution III)
**Scale/Scope**: Single-user CLI workflow

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Terminal-First Design | ✅ PASS | CLI-only, parseable output, JSON via `--json` flag (existing pattern), POSIX exit codes |
| II. Byobu Session Integrity | ✅ N/A | Feature does not interact with byobu sessions |
| III. Code Quality Standards | ✅ PASS | Will create modular `rename-branch.sh` helper (<50 line functions), descriptive error messages |
| IV. Performance Requirements | ✅ PASS | `git branch -m` is instantaneous; `git ls-remote` adds ~100-300ms for remote check (acceptable) |
| V. Graceful Degradation | ✅ PASS | Handles missing git, non-temp branches, rename failures without blocking spec creation |

**Gate Result**: PASS - No violations requiring justification.

## Project Structure

### Documentation (this feature)

```text
specs/260201-krgf-speckit-branch-naming/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # N/A - no API contracts for shell scripts
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
.specify/scripts/bash/
├── common.sh            # Existing: shared utilities (get_repo_root, clean_spec_name)
├── create-new-feature.sh # Modified: add --branch flag, call rename-branch.sh
└── rename-branch.sh     # NEW: encapsulated branch rename logic

.claude/commands/
└── speckit.specify.md   # Modified: document --branch flag, update examples
```

**Structure Decision**: Follows existing pattern of modular bash scripts in `.specify/scripts/bash/`. New functionality in separate file (`rename-branch.sh`) per single-responsibility principle.

## Complexity Tracking

> No Constitution violations - section not required.

