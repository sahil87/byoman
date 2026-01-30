# CLI Contract: byoman

**Phase 1 Output** | **Date**: 2026-01-31

## Overview

`byoman` is a terminal UI for managing tmux sessions. It operates in three modes:
- **TUI mode** (default): Interactive interface with keyboard navigation
- **List mode** (`--list`): Simple text output for piping/scripting
- **JSON mode** (`--json`): Machine-readable output

---

## Command Synopsis

```
byoman [flags]
byoman [command]

Commands:
  (none)          Launch TUI session manager (default)
  version         Print version information

Flags:
  -l, --list      List sessions as text (non-interactive)
  -j, --json      Output session list as JSON
      --no-color  Disable colored output
  -h, --help      Show help
  -v, --version   Print version
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error (tmux error, operation failed) |
| 2 | Invalid arguments |
| 127 | tmux not found |

---

## TUI Mode (Default)

### Launch Behavior

```bash
# Auto-detects TTY, launches interactive UI
byoman

# Explicit TUI mode (for scripts that want to force interactive)
byoman --tui
```

### Keyboard Bindings

| Key | Action |
|-----|--------|
| `j` / `↓` | Move cursor down |
| `k` / `↑` | Move cursor up |
| `Enter` | Attach to selected session |
| `n` | Create new session (prompts for name) |
| `r` | Rename selected session (prompts for name) |
| `x` / `d` | Kill selected session (confirmation prompt) |
| `?` | Toggle help |
| `q` / `Ctrl+C` | Quit |

### Display Format

```
┌─ tmux sessions ─────────────────────────────────────────────────┐
│                                                                  │
│  > dev         attached   3 windows   vim, zsh           2h ago │
│    api         detached   2 windows   node, zsh          1d ago │
│    infra       detached   1 window    kubectl            5d ago │
│                                                                  │
│  ↑/k up • ↓/j down • enter attach • n new • r rename • x kill  │
└──────────────────────────────────────────────────────────────────┘
```

### Confirmation Prompt (Kill)

```
Kill session 'dev'? [y/N] _
```

### Input Prompt (New/Rename)

```
New session name: my-project_
```

---

## List Mode (`--list`)

### Output Format

```bash
$ byoman --list
dev       attached   3 windows   2h ago
api       detached   2 windows   1d ago
infra     detached   1 window    5d ago
```

### Columns (tab-separated)

1. Session name
2. Status (attached/detached)
3. Window count
4. Time since last attached

### Empty State

```bash
$ byoman --list
# (no output, exit 0)
```

### Error State

```bash
$ byoman --list
Error: tmux not running
# exit 1
```

---

## JSON Mode (`--json`)

### Output Format

```bash
$ byoman --json
```

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

### Empty State

```json
{
  "sessions": []
}
```

### Error State

```json
{
  "error": {
    "code": "TMUX_NOT_RUNNING",
    "message": "tmux server is not running",
    "suggestion": "Start tmux with: tmux new-session"
  }
}
```

---

## Error Messages

All errors follow the format:
```
Error: {what happened}
Cause: {why it happened}
Fix: {suggested remediation}
```

### Error Catalog

| Code | Message | Suggestion |
|------|---------|------------|
| `TMUX_NOT_FOUND` | tmux is not installed | Install tmux: brew install tmux |
| `TMUX_VERSION` | tmux version 2.9 is below minimum 3.0 | Upgrade tmux to 3.0+ |
| `TMUX_NOT_RUNNING` | tmux server is not running | Start tmux with: tmux new-session |
| `TMUX_PERMISSION` | Cannot access tmux socket | Check socket permissions at /tmp/tmux-*/default |
| `SESSION_NOT_FOUND` | Session 'name' does not exist | The session may have been killed externally |
| `SESSION_EXISTS` | Session 'name' already exists | Choose a different name |
| `INVALID_NAME` | Session name contains invalid characters | Names cannot contain : or . characters |

---

## Environment Variables

| Variable | Effect |
|----------|--------|
| `NO_COLOR` | When set (any value), disables colored output |
| `TMUX` | When set, indicates running inside tmux |
| `TERM` | Used for terminal capability detection |

---

## Shell Integration

### tmux Keybinding

```tmux
# Add to ~/.tmux.conf
bind-key s run-shell "byoman"
```

### Alias

```bash
# Add to ~/.bashrc or ~/.zshrc
alias bs="byoman"
```

### Scripting Examples

```bash
# List all session names
byoman --list | cut -f1

# Check if session exists
byoman --json | jq -e '.sessions[] | select(.name == "dev")' > /dev/null

# Get attached session name
byoman --json | jq -r '.sessions[] | select(.attached) | .name'
```
