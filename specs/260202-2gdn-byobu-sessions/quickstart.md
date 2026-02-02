# Quickstart: Byobu Sessions Implementation

**Feature**: 260202-2gdn-byobu-sessions
**Date**: 2026-02-02

## Prerequisites

1. Go 1.21+ installed
2. byobu installed (`brew install byobu` or `apt install byobu`)
3. Repository cloned

## Implementation Steps

### Step 1: Modify CheckVersion()

**File**: `internal/tmux/client.go:30-68`

Replace the tmux version check with byobu existence check:

```go
// CheckVersion verifies byobu is installed.
// Returns nil if OK, error otherwise.
func CheckVersion() error {
    _, err := exec.LookPath("byobu")
    if err != nil {
        return fmt.Errorf("byobu is not installed.\n\nInstall with:\n  macOS:   brew install byobu\n  Ubuntu:  sudo apt install byobu\n  Fedora:  sudo dnf install byobu")
    }
    return nil
}
```

### Step 2: Replace tmux with byobu in All Commands

**File**: `internal/tmux/client.go`

Find and replace all `exec.Command("tmux", ...)` with `exec.Command("byobu", ...)`:

| Line | Current | Replace With |
|------|---------|--------------|
| 74 | `exec.Command("tmux", "list-sessions", ...)` | `exec.Command("byobu", "list-sessions", ...)` |
| 125 | `exec.Command("tmux", "list-panes", ...)` | `exec.Command("byobu", "list-panes", ...)` |
| 176 | `exec.Command("tmux", args...)` | `exec.Command("byobu", args...)` |
| 196 | `exec.Command("tmux", "rename-session", ...)` | `exec.Command("byobu", "rename-session", ...)` |
| 215 | `exec.Command("tmux", "kill-session", ...)` | `exec.Command("byobu", "kill-session", ...)` |

### Step 3: Update AttachSessionArgs()

**File**: `internal/tmux/client.go:229-238`

```go
func (c *DefaultClient) AttachSessionArgs(name string) (binary string, args []string, err error) {
    binary, err = exec.LookPath("byobu")
    if err != nil {
        return "", nil, fmt.Errorf("byobu not found: %w", err)
    }
    args = []string{"byobu", "attach-session", "-t", name}
    return binary, args, nil
}
```

### Step 4: Update Error Messages

Replace error messages that reference "tmux" with "byobu":

- Line 86: `"tmux list-sessions: %s"` → `"byobu list-sessions: %s"`
- Line 137: `"tmux list-panes: %s"` → `"byobu list-panes: %s"`
- Line 185: `"tmux new-session: %s"` → `"byobu new-session: %s"`
- Line 208: `"tmux rename-session: %s"` → `"byobu rename-session: %s"`
- Line 224: `"tmux kill-session: %s"` → `"byobu kill-session: %s"`

## Verification

### Build

```bash
go build -o byoman ./cmd/byoman
```

### Test Manually

```bash
# Verify byobu detection
./byoman
# Should show TUI if byobu installed, or error message if not

# Create a session
# Press 'n' in TUI, enter name, verify session has byobu status bar

# Attach to session
# Select session, press Enter, verify byobu keybindings work (F1 for help)
```

### Run Tests (once added)

```bash
go test ./internal/tmux/...
```

## Success Criteria Checklist

- [ ] SC-001: New sessions display byobu's status bar
- [ ] SC-002: Byobu keybindings (F1-F12) work in sessions
- [ ] SC-003: User's byobu profile settings are applied
- [ ] SC-004: All operations (list, rename, kill, attach) work
- [ ] SC-005: Error messages include install instructions
