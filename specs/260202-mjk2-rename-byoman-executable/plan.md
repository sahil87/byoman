# Implementation Plan: Rename Executable from byosm to byoman

**Branch**: `260202-mjk2-rename-byoman-executable` | **Date**: 2026-02-02 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/260202-mjk2-rename-byoman-executable/spec.md`

## Summary

Rename the Go module and executable from `byosm` to `byoman`. This is a purely cosmetic refactor affecting module declarations, import statements, and documentation. No functional changes to the byobu session manager TUI.

## Technical Context

**Language/Version**: Go 1.21+ (existing project)
**Primary Dependencies**: bubbletea (TUI framework), lipgloss (styling), bubbles (input components) - unchanged
**Storage**: N/A (session data sourced from tmux at runtime)
**Testing**: `go build ./...` for compilation verification
**Target Platform**: macOS, Linux (terminal environments)
**Project Type**: single CLI application
**Performance Goals**: Command startup <100ms (per constitution)
**Constraints**: No functional changes - rename only
**Scale/Scope**: 12 files requiring updates

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Compliance | Notes |
|-----------|------------|-------|
| I. Terminal-First Design | ✅ PASS | No change - command name `byoman` maintains terminal workflow |
| II. Byobu Session Integrity | ✅ PASS | No change to session management |
| III. Code Quality Standards | ✅ PASS | Simple rename maintains code quality |
| IV. Performance Requirements | ✅ PASS | No performance impact from rename |
| V. Graceful Degradation | ✅ PASS | No change to error handling |

**Gate Status**: ✅ PASSED - No violations. Proceed to implementation.

## Project Structure

### Documentation (this feature)

```text
specs/260202-mjk2-rename-byoman-executable/
├── plan.md              # This file
├── research.md          # Phase 0 output (minimal - straightforward rename)
├── quickstart.md        # Phase 1 output (build & verify instructions)
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
# Existing structure (unchanged by this feature)
cmd/
└── byosm/               # → RENAME TO: cmd/byoman/
    └── main.go

internal/
├── app/
│   └── app.go           # UPDATE: import paths byosm → byoman
├── tmux/
│   ├── session.go
│   └── window.go
└── tui/
    ├── model.go         # UPDATE: import paths byosm → byoman
    ├── update.go        # UPDATE: import paths byosm → byoman
    └── view.go

go.mod                   # UPDATE: module byosm → module byoman
.gitignore               # UPDATE: remove duplicate byosm entry
```

**Structure Decision**: No structural changes required. This is a rename affecting identifiers only.

## Files Requiring Changes

### Category 1: Go Module & Build (Critical Path)

| File | Change Required |
|------|-----------------|
| `go.mod` | Line 1: `module byosm` → `module byoman` |
| `cmd/byosm/` → `cmd/byoman/` | Rename directory |

### Category 2: Go Import Statements

| File | Line(s) | Change |
|------|---------|--------|
| `internal/app/app.go` | 4, 5 | `"byosm/internal/..."` → `"byoman/internal/..."` |
| `internal/tui/model.go` | 4 | `"byosm/internal/tmux"` → `"byoman/internal/tmux"` |
| `internal/tui/update.go` | 4 | `"byosm/internal/tmux"` → `"byoman/internal/tmux"` |

### Category 3: Configuration

| File | Change |
|------|--------|
| `.gitignore` | Remove `byosm` entry (line 14); keep `byoman` (line 15) |

### Category 4: Documentation (7 files)

| File | Type |
|------|------|
| `specs/260201-2o4w-byoby-session-manager/plan.md` | Binary name reference |
| `specs/260201-2o4w-byoby-session-manager/contracts/cli-interface.md` | CLI documentation |
| `specs/260201-2o4w-byoby-session-manager/quickstart.md` | Build instructions |
| `specs/260201-2o4w-byoby-session-manager/tasks.md` | Task descriptions |

## Implementation Order

1. **Module Declaration** - Update `go.mod`
2. **Directory Rename** - `mv cmd/byosm cmd/byoman`
3. **Import Statements** - Update 3 Go source files
4. **Configuration** - Clean up `.gitignore`
5. **Verification** - `go build -o byoman ./cmd/byoman && ./byoman`
6. **Documentation** - Update spec files

## Complexity Tracking

> No Constitution Check violations. No complexity justification needed.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| *None* | — | — |
