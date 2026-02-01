# Implementation Plan: Worktree Lifecycle Scripts

**Branch**: `260201-gvao-wt-lifecycle-scripts` | **Date**: 2026-02-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/260201-gvao-wt-lifecycle-scripts/spec.md`

## Summary

Three standalone POSIX-compliant shell scripts (`wt-delete`, `wt-pr`, `wt-merge`) that complete the worktree lifecycle workflow started by `wt-create`. Scripts follow existing patterns: numbered menus, `what/why/fix` error format, cross-platform support (macOS/Linux), and consistent exit codes.

## Technical Context

**Language/Version**: Bash (POSIX-compliant shell scripts, tested with bash 3.2+ and bash 5+)
**Primary Dependencies**: git (core), gh CLI (required for `wt-merge`, optional with fallback for `wt-pr`)
**Storage**: N/A (git manages all metadata)
**Testing**: Manual testing + shell script linting (shellcheck)
**Target Platform**: macOS (Darwin), Linux (Ubuntu, other distributions)
**Project Type**: Single project (standalone CLI scripts)
**Performance Goals**: <100ms startup per Constitution IV (terminal interactions feel instantaneous)
**Constraints**: POSIX-compatible, no external dependencies beyond git and optional gh CLI
**Scale/Scope**: 3 scripts, ~300-400 lines each following `wt-create` patterns

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence/Notes |
|-----------|--------|----------------|
| **I. Terminal-First Design** | ✅ PASS | Scripts support interactive (menus) and non-interactive (flags) modes; parseable output; POSIX exit codes |
| **II. Byobu Session Integrity** | ✅ N/A | Not applicable - these scripts don't interact with byobu sessions |
| **III. Code Quality Standards** | ✅ PASS | Functions <50 lines following `wt-create` patterns; `what/why/fix` error format per spec FR-029 |
| **IV. Performance Requirements** | ✅ PASS | Shell scripts with minimal dependencies; startup <100ms achievable |
| **V. Graceful Degradation** | ✅ PASS | `wt-pr` falls back to browser when `gh` unavailable; clear error messages; handles missing worktrees |

**Gate Result**: PASS - No violations requiring justification.

## Project Structure

### Documentation (this feature)

```text
specs/260201-gvao-wt-lifecycle-scripts/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── cli-interface.md # CLI interface specification
└── tasks.md             # Phase 2 output (via /speckit.tasks)
```

### Source Code (repository root)

```text
bin/
├── wt-create            # Existing script (reference implementation)
├── wt-delete            # New: Worktree deletion with cleanup
├── wt-pr                # New: PR creation workflow
└── wt-merge             # New: PR merge + cleanup workflow
```

**Structure Decision**: Scripts placed in `bin/` directory alongside existing `wt-create` for consistency. No `src/` or `tests/` directories as these are standalone shell scripts following the existing pattern.

## Complexity Tracking

> No Constitution violations requiring justification.
