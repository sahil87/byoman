# Data Model: tmux Session Manager

**Branch**: `260201-2o4w-byoby-session-manager` | **Date**: 2026-02-01

## Overview

This tool has no persistent storage—all data is read from tmux at runtime. The data model defines the Go structs used to represent tmux state.

## Entities

### Session

Primary entity representing a tmux session.

```go
// internal/tmux/types.go

type Session struct {
    Name         string        // Unique identifier (tmux session name)
    ID           string        // tmux internal ID (e.g., "$0")
    Created      time.Time     // When session was created
    LastAttached time.Time     // Last time a client attached
    Attached     int           // Number of attached clients (0 = detached)
    WindowCount  int           // Number of windows in session
    Windows      []Window      // Window details (optional, loaded on demand)
}

// IsDetached returns true if no clients are attached
func (s Session) IsDetached() bool {
    return s.Attached == 0
}

// Status returns "attached" or "detached" string
func (s Session) Status() string {
    if s.Attached > 0 {
        return "attached"
    }
    return "detached"
}
```

**Source**: `tmux list-sessions -F '#{session_name}\t#{session_id}\t#{session_created}\t#{session_last_attached}\t#{session_attached}\t#{session_windows}'`

**Validation Rules**:
- `Name` must be non-empty
- `Name` must be unique across all sessions (enforced by tmux)
- `Created` and `LastAttached` are Unix timestamps from tmux

---

### Window

A window within a session (displayed in FR-006, FR-007).

```go
type Window struct {
    Index       int           // Window index within session (0-based)
    Name        string        // Window name
    ID          string        // tmux internal ID (e.g., "@0")
    PaneCount   int           // Number of panes
    Active      bool          // Is this the active window?
    Panes       []Pane        // Pane details
}
```

**Source**: `tmux list-windows -t SESSION -F '#{window_index}\t#{window_name}\t#{window_id}\t#{window_panes}\t#{window_active}'`

---

### Pane

A terminal pane within a window (used for FR-007: current running command).

```go
type Pane struct {
    Index          int        // Pane index within window (0-based)
    ID             string     // tmux internal ID (e.g., "%0")
    CurrentCommand string     // Foreground process (e.g., "vim", "zsh")
    CurrentPath    string     // Working directory
    Active         bool       // Is this the active pane?
}
```

**Source**: `tmux list-panes -t SESSION:WINDOW -F '#{pane_index}\t#{pane_id}\t#{pane_current_command}\t#{pane_current_path}\t#{pane_active}'`

---

## Relationships

```
Session (1) ──────< Window (many)
Window  (1) ──────< Pane   (many)
```

- A Session contains 1+ Windows
- A Window contains 1+ Panes
- Relationships are hierarchical (no cross-references)

---

## TUI State Model

The bubbletea model maintains UI state separate from tmux data.

```go
// internal/tui/model.go

type ViewState int

const (
    StateList ViewState = iota
    StateConfirmKill
    StateNewSession
    StateRenameSession
)

type Model struct {
    // Data
    sessions []tmux.Session

    // UI State
    list         list.Model    // bubbles/list component
    state        ViewState     // Current view/mode
    selectedName string        // Preserved during refresh

    // Confirmation state
    confirmTarget string       // Session name pending confirmation

    // Input state (for new/rename)
    textInput textinput.Model

    // Output
    selectedSession string     // Populated on Enter, triggers attach
    quitting        bool       // True when exiting
    err             error      // Last error
}
```

**State Transitions**:

```
StateList
  ├─ [k] → StateConfirmKill
  │         ├─ [y] → kill session → StateList
  │         └─ [any] → StateList (cancel)
  ├─ [n] → StateNewSession
  │         ├─ [Enter] → create session → StateList
  │         └─ [Esc] → StateList (cancel)
  ├─ [r] → StateRenameSession
  │         ├─ [Enter] → rename session → StateList
  │         └─ [Esc] → StateList (cancel)
  ├─ [Enter] → set selectedSession, quit → exec tmux attach
  └─ [q] → quit
```

---

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                         main.go                              │
│  1. Initialize Model                                         │
│  2. p.Run() → bubbletea event loop                          │
│  3. On quit: if selectedSession != "" → syscall.Exec(tmux)  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    internal/tui/model.go                     │
│  Init():                                                     │
│    - loadSessions() command                                  │
│    - tickCmd() for auto-refresh                             │
│                                                              │
│  Update(msg):                                                │
│    - tickMsg → loadSessions() + tickCmd()                   │
│    - sessionsLoadedMsg → updateList, preserve selection     │
│    - tea.KeyMsg → handle navigation, actions                │
│                                                              │
│  View():                                                     │
│    - Render list with lipgloss styles                       │
│    - Render confirmation prompt if in confirm state         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   internal/tmux/client.go                    │
│  ListSessions() → exec tmux, parse output → []Session       │
│  KillSession(name) → exec tmux kill-session                 │
│  NewSession(name) → exec tmux new-session -d                │
│  RenameSession(old, new) → exec tmux rename-session         │
│  AttachSession(name) → returns args for syscall.Exec        │
└─────────────────────────────────────────────────────────────┘
```

---

## Validation

| Field | Rule | Error Message |
|-------|------|---------------|
| Session.Name (create/rename) | Non-empty | "Session name cannot be empty" |
| Session.Name (create/rename) | Unique | "Session 'X' already exists" |
| Session.Name (create/rename) | Valid characters | "Session name contains invalid characters" |

tmux enforces most validation; we surface its error messages to the user.
