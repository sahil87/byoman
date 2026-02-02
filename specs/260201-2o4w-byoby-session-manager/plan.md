# Implementation Plan: tmux Session Manager

**Branch**: `260201-2o4w-byoby-session-manager` | **Date**: 2026-02-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/260201-2o4w-byoby-session-manager/spec.md`

## Summary

Interactive TUI tool for managing tmux sessions: list all sessions with metrics (created time, last attached, window count, running commands), attach to sessions, create new sessions, rename sessions, and kill sessions with confirmation. Built as a single Go binary using the bubbletea/lipgloss ecosystem for terminal UI.

## Technical Context

**Language/Version**: Go 1.21+ (compiled single binary, no runtime dependencies)
**Primary Dependencies**: bubbletea (TUI framework), lipgloss (styling), bubbles (input components)
**Storage**: N/A (all session data sourced directly from tmux at runtime)
**Testing**: go test (Go's standard testing framework)
**Target Platform**: Any system with tmux 3.0+ (macOS, Linux)
**Project Type**: single (CLI tool)
**Performance Goals**: Startup <100ms, session listing <500ms, UI auto-refresh every 2-5s
**Constraints**: Memory <50MB, <100ms startup for simple operations
**Scale/Scope**: 1-20 sessions typical; simple scrollable list (no pagination/search)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Compliance | Notes |
|-----------|------------|-------|
| **I. Terminal-First Design** | ✅ PASS | TUI optimized for terminal; go binary has single-letter keybindings (n/r/k/q); exit via q key |
| **II. Byobu Session Integrity** | ✅ PASS | Kill requires inline confirmation; read-only by default; data sourced directly from tmux (no hidden state) |
| **III. Code Quality Standards** | ✅ PASS | Go packages enforce modular structure; error messages will include what/why/remediation |
| **IV. Performance Requirements** | ✅ PASS | Targets align: startup <100ms, list <500ms; memory <50MB; Go is fast startup |
| **V. Graceful Degradation** | ✅ PASS | Clear error if tmux not installed or version <3.0; handles stale sessions gracefully |

**Pre-Phase 0 Gate**: ✅ PASSED - No violations requiring justification

## Project Structure

### Documentation (this feature)

```text
specs/260201-2o4w-byoby-session-manager/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
cmd/
└── byoman/              # Main entry point (byobu session manager)
    └── main.go

internal/
├── tmux/                # tmux interaction layer
│   ├── client.go        # Execute tmux commands, parse output
│   └── types.go         # Session, Window, Pane types
├── tui/                 # bubbletea UI components
│   ├── model.go         # Main model with state
│   ├── view.go          # Render session list
│   ├── update.go        # Handle key events
│   └── styles.go        # lipgloss styles
└── app/                 # Application orchestration
    └── app.go           # Wire together tmux + tui

tests/
├── integration/         # End-to-end tests with real tmux
└── unit/                # Unit tests with mocked tmux
```

**Structure Decision**: Single Go module with standard `cmd/` + `internal/` layout. The `internal/tmux` package encapsulates all tmux CLI interaction. The `internal/tui` package contains the bubbletea model, view, and update logic. Clean separation allows unit testing with mocked tmux client.

## Post-Design Constitution Re-Check

*Re-evaluation after Phase 1 design artifacts completed.*

| Principle | Compliance | Design Validation |
|-----------|------------|-------------------|
| **I. Terminal-First Design** | ✅ PASS | CLI interface contract defines 80-col layout; keybindings documented; exit codes follow POSIX |
| **II. Byobu Session Integrity** | ✅ PASS | Data model shows read-only by default; kill requires confirmation; no hidden state |
| **III. Code Quality Standards** | ✅ PASS | Project structure has clear separation (tmux/tui/app); functions will be <50 lines; error messages specified in contract |
| **IV. Performance Requirements** | ✅ PASS | Performance contract specifies: startup <100ms, list <200ms target; aligns with constitution |
| **V. Graceful Degradation** | ✅ PASS | Error handling defined: "no server running" → graceful message; version check on startup |

**Post-Phase 1 Gate**: ✅ PASSED - Design artifacts comply with all constitution principles

## Complexity Tracking

> No Constitution Check violations. Table omitted.
