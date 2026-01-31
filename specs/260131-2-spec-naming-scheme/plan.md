# Implementation Plan: Spec Naming Scheme Update

**Branch**: `260132-spec-naming-scheme` | **Date**: 2026-01-31 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/260132-spec-naming-scheme/spec.md`

## Summary

Update speckit's `create-new-feature.sh` script to generate spec directory names using format `{YYMMDD}-{4-char-random}-{slug}` instead of the current sequential `{NNN}-{slug}` format. This provides chronological ordering and uniqueness without requiring central coordination.

## Technical Context

**Language/Version**: Bash (POSIX-compliant shell scripts)
**Primary Dependencies**: Standard POSIX utilities (date, tr, head, /dev/urandom or $RANDOM)
**Storage**: Filesystem (specs/ directory)
**Testing**: Manual verification + shell script execution tests
**Target Platform**: macOS/Linux terminal (both must be supported)
**Project Type**: Single project (CLI tooling)
**Performance Goals**: <100ms for spec creation (aligns with Constitution IV)
**Constraints**: Must coexist with existing specs (no migration), filesystem-safe characters only
**Scale/Scope**: Local development workflow, single-user, ~10-50 specs per project

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Terminal-First Design | ✅ PASS | Script outputs human-readable by default, JSON via `--json` flag; exit codes follow POSIX |
| II. Byobu Session Integrity | N/A | Feature does not interact with byobu sessions |
| III. Code Quality Standards | ✅ PASS | Script is <500 lines; changes add clear comments for new functions |
| IV. Performance Requirements | ✅ PASS | Spec creation target <100ms; uses efficient POSIX utilities |
| V. Graceful Degradation | ✅ PASS | Handles collision detection by regenerating random string |

**Gate Status**: ✅ PASS - No violations. Proceed to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/260132-spec-naming-scheme/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # N/A - no data model changes
├── quickstart.md        # Phase 1 output
├── contracts/           # N/A - no API contracts
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
.specify/scripts/bash/
├── create-new-feature.sh  # PRIMARY: Modify naming scheme logic
├── common.sh              # No changes needed
├── list-specs.sh          # No changes needed (name-agnostic)
├── set-current.sh         # No changes needed (name-agnostic)
└── setup-plan.sh          # No changes needed (name-agnostic)
```

**Structure Decision**: Single project structure. Only `create-new-feature.sh` requires modification. Other scripts are name-format agnostic and will work with both old (`NNN-slug`) and new (`YYMMDD-XXXX-slug`) formats.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No violations - table intentionally empty.*
