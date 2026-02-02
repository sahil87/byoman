# Data Model: Byobu Sessions

**Feature**: 260202-2gdn-byobu-sessions
**Date**: 2026-02-02

## Overview

This feature does not introduce new data models. The existing data structures from `internal/tmux/types.go` remain unchanged since byobu uses the same session format as tmux.

## Existing Entities (Unchanged)

### Session

**Location**: `internal/tmux/types.go`

| Field | Type | Description |
|-------|------|-------------|
| Name | string | Session name (unique identifier) |
| ID | string | Session ID (e.g., "$1") |
| Created | time.Time | When session was created |
| LastAttached | time.Time | Last attachment timestamp |
| Attached | int | Number of attached clients |
| WindowCount | int | Number of windows in session |

**Relationships**:
- Session has many Windows (not modeled in code, queried separately)
- Session has many Panes (via GetPaneCommands())

### Pane Commands

**Location**: Returned by `GetPaneCommands()` in `internal/tmux/client.go`

| Field | Type | Description |
|-------|------|-------------|
| SessionName | string (map key) | Session the pane belongs to |
| Commands | []string (map value) | Unique commands running in session panes |

## Data Flow (No Changes)

```
byobu list-sessions -F <format>
         ↓
    Parse stdout
         ↓
    []Session slice
         ↓
    TUI model.sessions
```

## Notes

- No new entities introduced
- No state transitions affected
- No validation rules changed
- Byobu session data is identical to tmux session data
