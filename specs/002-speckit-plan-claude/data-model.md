# Data Model: tmux Session Manager

**Phase 1 Output** | **Date**: 2026-01-31

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                           tmux Server                            │
│  (external system - accessed via tmux commands)                  │
└─────────────────────────────────────────────────────────────────┘
                                │
                                │ 1:N
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                            Session                               │
│  ─────────────────────────────────────────────────────────────  │
│  name: string (unique, primary identifier)                       │
│  id: string (tmux internal ID, e.g., "$0")                      │
│  createdAt: time.Time                                           │
│  lastAttachedAt: *time.Time (nullable - never attached)         │
│  attachedClients: int (0 = detached)                            │
│  windowCount: int                                                │
└─────────────────────────────────────────────────────────────────┘
                                │
                                │ 1:N
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                            Window                                │
│  ─────────────────────────────────────────────────────────────  │
│  index: int (0-based within session)                            │
│  id: string (tmux internal ID, e.g., "@0")                      │
│  name: string                                                    │
│  active: bool                                                    │
│  paneCount: int                                                  │
└─────────────────────────────────────────────────────────────────┘
                                │
                                │ 1:N
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                             Pane                                 │
│  ─────────────────────────────────────────────────────────────  │
│  index: int (0-based within window)                             │
│  id: string (tmux internal ID, e.g., "%0")                      │
│  currentCommand: string (e.g., "vim", "zsh", "npm run dev")     │
│  currentPath: string                                             │
│  active: bool                                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Go Type Definitions

### Session Entity

```go
// internal/tmux/session.go

package tmux

import "time"

// Session represents a tmux session with its metadata.
// This is the primary entity displayed in the TUI list.
type Session struct {
    // Name is the unique identifier for the session.
    // Used as target for tmux commands (attach, kill, rename).
    Name string

    // ID is the tmux internal session ID (e.g., "$0", "$1").
    // Stable across renames; useful for tracking.
    ID string

    // CreatedAt is when the session was first created.
    CreatedAt time.Time

    // LastAttachedAt is when a client last attached.
    // Nil if never attached since creation.
    LastAttachedAt *time.Time

    // AttachedClients is the number of clients currently attached.
    // 0 means detached, >0 means attached.
    AttachedClients int

    // WindowCount is the number of windows in this session.
    WindowCount int

    // Windows contains detailed window/pane info when loaded.
    // Lazily populated only when needed for display.
    Windows []Window
}

// IsAttached returns true if any client is attached to this session.
func (s Session) IsAttached() bool {
    return s.AttachedClients > 0
}

// Status returns a human-readable status string.
func (s Session) Status() string {
    if s.IsAttached() {
        return "attached"
    }
    return "detached"
}
```

### Window Entity

```go
// Window represents a tmux window within a session.
type Window struct {
    // Index is the 0-based window number within the session.
    Index int

    // ID is the tmux internal window ID (e.g., "@0").
    ID string

    // Name is the window name (may be auto-set from running command).
    Name string

    // Active indicates if this is the currently selected window.
    Active bool

    // PaneCount is the number of panes in this window.
    PaneCount int

    // Panes contains pane details when loaded.
    Panes []Pane
}
```

### Pane Entity

```go
// Pane represents a tmux pane within a window.
type Pane struct {
    // Index is the 0-based pane number within the window.
    Index int

    // ID is the tmux internal pane ID (e.g., "%0").
    ID string

    // CurrentCommand is the command currently running in the pane.
    // e.g., "vim", "zsh", "node server.js"
    CurrentCommand string

    // CurrentPath is the working directory of the pane.
    CurrentPath string

    // Active indicates if this is the currently selected pane.
    Active bool
}
```

---

## Validation Rules

### Session Name Validation

```go
// internal/tmux/validation.go

import (
    "errors"
    "regexp"
)

var (
    ErrEmptyName     = errors.New("session name cannot be empty")
    ErrInvalidName   = errors.New("session name contains invalid characters")
    ErrNameExists    = errors.New("session name already exists")
    ErrNameTooLong   = errors.New("session name exceeds 256 characters")
)

// ValidSessionName matches tmux session name rules:
// - Cannot contain colons or periods (used as separators)
// - Cannot start with $ (reserved for IDs)
var validSessionName = regexp.MustCompile(`^[^:.$][^:.]*$`)

// ValidateName checks if a session name is valid for create/rename.
func ValidateName(name string) error {
    if name == "" {
        return ErrEmptyName
    }
    if len(name) > 256 {
        return ErrNameTooLong
    }
    if !validSessionName.MatchString(name) {
        return ErrInvalidName
    }
    return nil
}

// ValidateNameUnique checks if name is not already used.
func ValidateNameUnique(name string, existing []Session) error {
    for _, s := range existing {
        if s.Name == name {
            return ErrNameExists
        }
    }
    return nil
}
```

---

## State Transitions

### Session Lifecycle

```
                    ┌─────────────┐
                    │   (none)    │
                    └──────┬──────┘
                           │ create
                           ▼
                    ┌─────────────┐
        ┌──────────►│   created   │◄──────────┐
        │           │  (detached) │           │
        │           └──────┬──────┘           │
        │                  │ attach           │
        │                  ▼                  │
        │           ┌─────────────┐           │
        │ detach    │  attached   │  detach   │
        └───────────┤             ├───────────┘
                    └──────┬──────┘
                           │ kill
                           ▼
                    ┌─────────────┐
                    │  destroyed  │
                    └─────────────┘
```

### TUI Mode Transitions

```
                    ┌─────────────┐
                    │   normal    │
                    │ (list view) │
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           │               │               │
           │ 'x' key       │ 'n' key       │ 'r' key
           ▼               ▼               ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │   confirm   │ │    input    │ │    input    │
    │ (kill? y/n) │ │ (new name)  │ │(rename to?) │
    └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
           │               │               │
           │ y/n/esc       │ enter/esc     │ enter/esc
           │               │               │
           └───────────────┴───────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   normal    │
                    └─────────────┘
```

---

## Data Loading Strategy

### Lazy Loading

```
Initial Load (fast):
  └─► list-sessions → Session[] (name, created, attached, windows count)

On Demand (when displaying pane commands):
  └─► list-panes -s -t session → populate Session.Windows[].Panes[]
```

### Refresh Strategy

- **Periodic**: Every 2 seconds via `tea.Tick`
- **On Action**: Immediately after create/rename/kill
- **Cursor Preservation**: Maintain selection by session name/ID across refreshes

---

## JSON Output Schema

For `--json` flag output:

```json
{
  "sessions": [
    {
      "name": "dev",
      "id": "$0",
      "createdAt": "2026-01-31T10:00:00Z",
      "lastAttachedAt": "2026-01-31T14:30:00Z",
      "attached": true,
      "attachedClients": 1,
      "windowCount": 3,
      "windows": [
        {
          "index": 0,
          "name": "editor",
          "active": true,
          "panes": [
            {
              "index": 0,
              "command": "nvim",
              "path": "/home/user/project"
            }
          ]
        }
      ]
    }
  ]
}
```
