# Implementation Plan: tmux Session Manager

**Branch**: `002-speckit-plan-claude` | **Date**: 2026-01-31 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-byobu-session-manager/spec.md`

## Summary

A TUI-based CLI tool to manage tmux sessions. The tool displays a list of all sessions with metrics (name, created time, last attached time, attachment status, window count, running commands) and allows users to attach, create, rename, and kill sessions via keyboard navigation. Implemented as a single Go binary using the bubbletea/lipgloss TUI framework.

## Technical Context

**Language/Version**: Go 1.21+ (compiled single binary, no runtime dependencies)  
**Primary Dependencies**: bubbletea (TUI framework), lipgloss (styling), bubbles (input components)  
**Storage**: N/A (all data sourced directly from tmux via shell commands)  
**Testing**: go test (standard Go testing with table-driven tests)  
**Target Platform**: Unix-like systems with tmux 3.0+ (Linux, macOS)
**Project Type**: Single CLI project  
**Performance Goals**: <500ms session listing (up to 100 sessions), <100ms startup  
**Constraints**: <50MB memory, single binary distribution, no config files required  
**Scale/Scope**: Supports up to 100 concurrent tmux sessions

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Post-Design Gates (Phase 1 Complete)

| Principle | Gate | Status |
|-----------|------|--------|
| **I. Terminal-First Design** | Output readable in 80-col terminal | ✅ PASS - TUI designed for terminal |
| | Support both interactive and scriptable modes | ✅ PASS - `--list` and `--json` flags (see contracts/cli.md) |
| | Parseable output (JSON via --json) | ✅ PASS - JSON schema defined (see data-model.md) |
| | Exit codes follow POSIX conventions | ✅ PASS - Exit codes 0/1/2/127 defined |
| | Respect NO_COLOR and --no-color | ✅ PASS - lipgloss auto-respects NO_COLOR (see research.md) |
| **II. Session Integrity** | Never destroy sessions without confirmation | ✅ PASS - Inline y/N prompt required |
| | Session state changes atomic | ✅ PASS - Uses tmux atomic commands |
| | Handle concurrent access | ✅ PASS - 2s refresh + graceful cursor handling (see research.md) |
| | Warn about corrupted sessions | ✅ PASS - Error catalog defined (see contracts/cli.md) |
| **III. Code Quality** | Functions <50 lines, files <500 lines | ✅ PASS - Structure enforces (see Project Structure) |
| | Public APIs have docstrings | ✅ PASS - Types documented (see data-model.md) |
| | User strings in single location | ✅ PASS - `internal/strings/strings.go` planned |
| | Error messages: what, why, remediation | ✅ PASS - Error format defined (see contracts/cli.md) |
| | No silent failures | ✅ PASS - All errors logged/displayed |
| **IV. Performance** | Startup <100ms | ✅ PASS - Go binary startup |
| | Session listing <500ms for 100 sessions | ✅ PASS - Simple tmux query |
| | Progress indicators for long ops | ✅ PASS - Spinner during session creation |
| | Memory <50MB | ✅ PASS - Minimal data structures |
| **V. Graceful Degradation** | Operate when tmux not installed | ✅ PASS - Clear error message |
| | Handle missing config (use defaults) | ✅ PASS - No config files required |
| | Log diagnostics to ~/.byoman/logs/ | ✅ PASS - `internal/logging/` planned |

### All Gates Passed ✅

No Constitution violations. All design needs resolved in Phase 1 artifacts.

## Project Structure

### Documentation (this feature)

```text
specs/002-speckit-plan-claude/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (CLI interface contract)
└── tasks.md             # Phase 2 output (not created by /speckit.plan)
```

### Source Code (repository root)

```text
cmd/
└── byoman/
    └── main.go              # Entry point

internal/
├── tmux/
│   ├── client.go            # tmux command execution
│   ├── session.go           # Session data structures
│   ├── parser.go            # Parse tmux output
│   └── client_test.go
├── tui/
│   ├── model.go             # bubbletea Model
│   ├── view.go              # Render functions
│   ├── update.go            # Message handling
│   ├── keys.go              # Keybindings
│   ├── styles.go            # lipgloss styles
│   └── model_test.go
├── strings/
│   └── strings.go           # All user-facing messages
└── logging/
    └── logger.go            # Debug logging utilities

go.mod
go.sum
Makefile
```

**Structure Decision**: Single Go CLI project using standard `cmd/` + `internal/` layout. The `internal/` package prevents external imports while organizing code by responsibility: `tmux/` for tmux interaction, `tui/` for terminal UI, `strings/` for centralized messages, and `logging/` for diagnostics.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations - all Constitution gates passed.

---

## Phase 1 Artifacts Generated

| Artifact | Path | Description |
|----------|------|-------------|
| Research | `research.md` | Technology decisions with rationale |
| Data Model | `data-model.md` | Entity definitions, validation rules, state transitions |
| CLI Contract | `contracts/cli.md` | Command interface, flags, output formats, error catalog |
| Quickstart | `quickstart.md` | Installation and usage guide |

## Next Steps

Phase 2 (`/speckit.tasks`) will generate `tasks.md` with implementation tasks based on these artifacts.
