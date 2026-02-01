# Implementation Plan: Consolidate bin/ into .specify/

**Branch**: `260201-gofw-consolidate-bin-specify` | **Date**: 2026-02-01 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/260201-gofw-consolidate-bin-specify/spec.md`

## Summary

Consolidate the bin/ directory into .specify/bin/ to clean up the project root while preserving all script functionality. This involves moving 6 shell scripts plus a subdirectory, updating internal path references, and updating documentation references.

## Technical Context

**Language/Version**: Bash (POSIX-compliant shell scripts, tested with bash 3.2+ and 5+)
**Primary Dependencies**: git (for worktree scripts), standard POSIX utilities
**Storage**: N/A (filesystem operations only)
**Testing**: Manual verification, shellcheck linting
**Target Platform**: macOS (Darwin), Linux
**Project Type**: Single project (shell script collection)
**Performance Goals**: N/A (no performance-sensitive operations)
**Constraints**: Must preserve executable permissions, must not break worktree scripts across cloned worktrees
**Scale/Scope**: 6 scripts + 1 subdirectory with 2 files

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Pre-Research Check ✅

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Terminal-First Design | ✅ PASS | Scripts already comply; relocation doesn't change behavior |
| II. Byobu Session Integrity | ✅ N/A | No session operations involved |
| III. Code Quality Standards | ✅ PASS | Scripts already under 50 lines (wt-setup) or properly structured; no changes to code logic |
| IV. Performance Requirements | ✅ PASS | No performance-impacting changes |
| V. Graceful Degradation | ✅ PASS | Scripts handle missing dependencies gracefully |

### Post-Design Re-Check ✅

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Terminal-First Design | ✅ PASS | No changes to script I/O behavior |
| II. Byobu Session Integrity | ✅ N/A | Still no session operations |
| III. Code Quality Standards | ✅ PASS | Only 1 line change in wt-create (path update) |
| IV. Performance Requirements | ✅ PASS | File moves have no runtime impact |
| V. Graceful Degradation | ✅ PASS | Path reference update maintains graceful error handling |

## Project Structure

### Documentation (this feature)

```text
specs/260201-gofw-consolidate-bin-specify/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

**Before**:
```text
bin/
├── speckit-build         # Speckit build orchestration
├── wt-create             # Worktree creation
├── wt-delete             # Worktree deletion
├── wt-merge              # Worktree merge workflow
├── wt-pr                 # Worktree PR creation
├── wt-setup              # Worktree setup/initialization
└── worktree-setup/       # Setup tasks subdirectory
    ├── 1-setup-claude-permissions.sh
    └── templates/
        └── settings.local.json

.specify/
├── current               # Current spec marker
├── memory/               # Constitution, etc.
├── scripts/              # Internal speckit scripts
│   └── bash/             # (existing scripts)
└── templates/            # Templates
```

**After**:
```text
.specify/
├── bin/                  # NEW: User-facing scripts
│   ├── speckit-build
│   ├── wt-create
│   ├── wt-delete
│   ├── wt-merge
│   ├── wt-pr
│   ├── wt-setup
│   └── worktree-setup/
│       ├── 1-setup-claude-permissions.sh
│       └── templates/
│           └── settings.local.json
├── current
├── memory/
├── scripts/              # Internal speckit scripts (unchanged)
│   └── bash/
└── templates/
```

**Structure Decision**: Move bin/ to .specify/bin/ to consolidate all project tooling within .specify/. This maintains a clear separation: `.specify/scripts/` for internal speckit machinery, `.specify/bin/` for user-facing CLI tools.

## Complexity Tracking

> **No violations identified** - All Constitution principles pass or are not applicable to this feature.

## References to Update

### Internal Script References
| File | Line | Current | New |
|------|------|---------|-----|
| bin/wt-create | 621 | `$wt_path/bin/wt-setup` | `$wt_path/.specify/bin/wt-setup` |
| bin/wt-setup | 7-8 | `$SCRIPT_DIR/worktree-setup` | `$SCRIPT_DIR/worktree-setup` (relative path - OK) |

### Documentation References
| File | Reference Pattern |
|------|------------------|
| .claude/commands/speckit.build.md | `bin/speckit-build` → `.specify/bin/speckit-build` |
| specs/260201-gvao-wt-lifecycle-scripts/quickstart.md | `bin/wt-*` → `.specify/bin/wt-*` |
| specs/260201-is0r-worktree-create-script/quickstart.md | `bin/wt-create` → `.specify/bin/wt-create` |
| specs/260201-gvao-wt-lifecycle-scripts/plan.md | `bin/` structure |
| specs/260201-is0r-worktree-create-script/plan.md | `bin/` structure |
| specs/260201-gvao-wt-lifecycle-scripts/tasks.md | `bin/wt-*` references |
| specs/260201-is0r-worktree-create-script/tasks.md | `bin/wt-create` references |

**Note**: Many documentation references are historical (describing past implementation) and may not require updates. The critical update is `.claude/commands/speckit.build.md` which contains the actual invocation path.
