# Implementation Plan: Byobu Sessions

**Branch**: `260202-2gdn-byobu-sessions` | **Date**: 2026-02-02 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/260202-2gdn-byobu-sessions/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Replace all tmux command invocations with byobu equivalents so that sessions created and attached via byoman include byobu's full feature set (status bar, keybindings, profiles). The change is minimal since byobu uses identical command syntax to tmux—primarily string replacements in `internal/tmux/client.go` and simplified version checking.

## Technical Context

**Language/Version**: Go 1.25.6
**Primary Dependencies**: bubbletea v1.3.10 (TUI), lipgloss v1.1.0 (styling), bubbles v0.21.0 (components)
**Storage**: N/A (all session data sourced from byobu/tmux at runtime)
**Testing**: go test (standard library) - no tests exist yet, adding recommended
**Target Platform**: macOS/Linux with byobu installed
**Project Type**: Single (CLI binary)
**Performance Goals**: <100ms command startup, <500ms session listing (per constitution)
**Constraints**: <50MB memory, offline-only (no network), byobu required on system
**Scale/Scope**: Single user, local terminal sessions (typically <20 sessions)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Terminal-First Design | ✅ Pass | No changes to CLI interface; byobu maintains same command syntax |
| II. Byobu Session Integrity | ✅ Pass | Switching to byobu enhances session management; no data operations change |
| III. Code Quality Standards | ✅ Pass | Changes are <50 lines; error messages will include remediation |
| IV. Performance Requirements | ✅ Pass | byobu overhead is negligible; same commands executed |
| V. Graceful Degradation | ✅ Pass | Error handling for missing byobu explicitly required (FR-003) |

**Pre-Design Gate**: PASSED - All principles satisfied

**Post-Design Re-check**: PASSED
- Data model unchanged (same Session struct)
- No API contracts needed (CLI tool)
- Implementation stays within single file (`internal/tmux/client.go`)

## Project Structure

### Documentation (this feature)

```text
specs/260202-2gdn-byobu-sessions/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output (minimal for this feature)
├── quickstart.md        # Phase 1 output
├── contracts/           # N/A - no API contracts
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
cmd/
└── byoman/
    └── main.go          # Entry point (may not exist yet)

internal/
├── app/
│   └── app.go           # Main orchestrator, calls CheckVersion()
├── tmux/
│   ├── client.go        # PRIMARY CHANGE TARGET: tmux → byobu commands
│   └── types.go         # Session, Window, Pane data types (no changes)
└── tui/
    ├── model.go         # TUI state management
    ├── update.go        # Keyboard handling
    ├── view.go          # Screen rendering
    └── styles.go        # Lipgloss styling

tests/                   # Recommended: add test files (none exist yet)
├── tmux/
│   └── client_test.go   # Unit tests for byobu client
└── integration/
    └── session_test.go  # Integration tests (optional)
```

**Structure Decision**: Single project structure (existing). Primary changes in `internal/tmux/client.go` with all `exec.Command("tmux", ...)` calls replaced by `exec.Command("byobu", ...)`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No violations. This feature is a straightforward command substitution.*
