# CLI Interface Contract: byosm

**Version**: 1.0.0 | **Date**: 2026-02-01

## Command

```bash
byosm [options]
```

**Binary name**: `byosm` (byobu session manager)

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `--help`, `-h` | Show help message | - |
| `--version`, `-v` | Show version | - |
| `--refresh SECONDS` | Auto-refresh interval | 3 |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Normal exit (user pressed q, or attached to session) |
| 1 | tmux not found or version < 3.0 |
| 2 | tmux server not running and no sessions |

## TUI Interface

### Layout

```
┌──────────────────────────────────────────────────────────┐
│  tmux sessions                                            │
├──────────────────────────────────────────────────────────┤
│  > dev          3 windows  (attached)   vim, zsh         │
│    work         2 windows  (detached)   htop             │
│    personal     1 window   (detached)   zsh              │
│                                                          │
│                                                          │
├──────────────────────────────────────────────────────────┤
│  [n]ew  [r]ename  [k]ill  [enter]attach  [q]uit          │
└──────────────────────────────────────────────────────────┘
```

### Session Row Format

```
{cursor} {name}    {windows} windows  ({status})  {commands}
```

| Field | Width | Description |
|-------|-------|-------------|
| cursor | 2 | `> ` when selected, `  ` otherwise |
| name | variable | Session name (left-aligned) |
| windows | variable | Window count (e.g., "3 windows") |
| status | ~10 | "(attached)" or "(detached)" |
| commands | variable | Comma-separated running commands |

### Keybindings

| Key | Action | State Required |
|-----|--------|----------------|
| `↑` / `k` | Move selection up | List view |
| `↓` / `j` | Move selection down | List view |
| `Enter` | Attach to selected session | List view, session selected |
| `n` | Start new session dialog | List view |
| `r` | Rename selected session dialog | List view, session selected |
| `k` | Kill selected session (with confirm) | List view, session selected |
| `q` / `Ctrl+C` | Quit | Any |
| `y` | Confirm action | Confirmation prompt |
| `n` / `Esc` / any | Cancel action | Confirmation prompt |

### Confirmation Prompt

When user presses `k` to kill a session:

```
Kill session 'dev'? [y/N]
```

- `y` or `Y`: Confirm and kill
- Any other key: Cancel

### New Session Dialog

When user presses `n`:

```
New session name: ▌

[Enter] create  [Esc] cancel
```

**Validation**:
- Empty name: Use tmux default naming
- Duplicate name: Show error "Session 'X' already exists"

### Rename Session Dialog

When user presses `r`:

```
Rename 'dev' to: ▌

[Enter] rename  [Esc] cancel
```

**Validation**:
- Empty name: Show error "Session name cannot be empty"
- Duplicate name: Show error "Session 'X' already exists"

### Error Display

Errors appear at the bottom of the screen:

```
Error: Session 'main' already exists
```

Errors auto-dismiss after 3 seconds or on any keypress.

## tmux Interaction Contract

### Required tmux Commands

| Operation | Command |
|-----------|---------|
| List sessions | `tmux list-sessions -F FORMAT` |
| List panes | `tmux list-panes -a -F FORMAT` |
| Kill session | `tmux kill-session -t NAME` |
| New session | `tmux new-session -d -s NAME` |
| Rename session | `tmux rename-session -t OLD NEW` |
| Attach session | `tmux attach-session -t NAME` (via syscall.Exec) |

### Format Strings

**Sessions**:
```
#{session_name}\t#{session_id}\t#{session_created}\t#{session_last_attached}\t#{session_attached}\t#{session_windows}
```

**Panes** (for running commands):
```
#{session_name}\t#{pane_current_command}
```

### Error Handling

| tmux Error | User Message |
|------------|--------------|
| "no server running" | "No tmux sessions. Press 'n' to create one." |
| "session not found" | "Session no longer exists. Refreshing..." |
| "duplicate session" | "Session 'X' already exists" |
| Command timeout (>5s) | "tmux not responding" |

## Performance Contract

| Operation | Target | Maximum |
|-----------|--------|---------|
| Startup to first render | <100ms | 200ms |
| Session list refresh | <200ms | 500ms |
| Kill session | <100ms | 300ms |
| Create session | <200ms | 500ms |
| Rename session | <100ms | 300ms |

## Accessibility

- Supports `NO_COLOR` environment variable
- Works in 80x24 terminal minimum
- No animations that could cause issues
- Clear focus indicators (cursor prefix)
