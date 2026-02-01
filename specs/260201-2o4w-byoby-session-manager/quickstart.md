# Quickstart: tmux Session Manager Development

**Branch**: `260201-2o4w-byoby-session-manager` | **Date**: 2026-02-01

## Prerequisites

- **Go 1.21+**: `go version` should show 1.21 or later
- **tmux 3.0+**: `tmux -V` should show 3.0 or later
- **Git**: For version control

## Project Setup

### 1. Initialize Go Module

```bash
# From repository root
go mod init github.com/yourusername/byosm

# Install dependencies
go get github.com/charmbracelet/bubbletea
go get github.com/charmbracelet/bubbles/list
go get github.com/charmbracelet/bubbles/textinput
go get github.com/charmbracelet/lipgloss
```

### 2. Create Directory Structure

```bash
mkdir -p cmd/byosm
mkdir -p internal/tmux
mkdir -p internal/tui
mkdir -p internal/app
mkdir -p tests/unit
mkdir -p tests/integration
```

### 3. Verify Setup

```bash
# Build
go build -o byosm ./cmd/byosm

# Run (requires tmux sessions to exist)
./byosm
```

## Development Workflow

### Build & Run

```bash
# Development build
go build -o byosm ./cmd/byosm && ./byosm

# Or use go run
go run ./cmd/byosm
```

### Testing

```bash
# Run all tests
go test ./...

# Run with coverage
go test -cover ./...

# Run specific package tests
go test ./internal/tmux/...

# Run with verbose output
go test -v ./...
```

### Linting

```bash
# Install golangci-lint if not present
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Run linter
golangci-lint run
```

## Test Environment Setup

### Create Test tmux Sessions

```bash
# Create a few sessions for testing
tmux new-session -d -s dev
tmux new-session -d -s work
tmux new-session -d -s personal

# Verify
tmux list-sessions
```

### Clean Up Test Sessions

```bash
tmux kill-server  # Kills all sessions
```

## Key Files to Implement

### Phase 1: Core tmux Interaction

1. **`internal/tmux/types.go`** - Session, Window, Pane structs
2. **`internal/tmux/client.go`** - tmux command execution and parsing

### Phase 2: TUI Framework

3. **`internal/tui/model.go`** - Bubbletea model with state
4. **`internal/tui/update.go`** - Event handling (keys, messages)
5. **`internal/tui/view.go`** - Render functions
6. **`internal/tui/styles.go`** - Lipgloss styles

### Phase 3: Integration

7. **`internal/app/app.go`** - Wire tmux client to TUI
8. **`cmd/byosm/main.go`** - Entry point, flag parsing, exec handoff

## Debugging Tips

### View tmux Data

```bash
# Session info in parseable format
tmux list-sessions -F '#{session_name}\t#{session_created}\t#{session_attached}\t#{session_windows}'

# Pane commands
tmux list-panes -a -F '#{session_name}\t#{pane_current_command}'
```

### Debug Bubbletea

```bash
# Enable debug logging
DEBUG=true go run ./cmd/byosm 2>debug.log
```

### Test Individual Commands

```bash
# Kill session
tmux kill-session -t dev

# New session
tmux new-session -d -s newone

# Rename session
tmux rename-session -t dev development
```

## Dependencies Reference

| Package | Purpose | Docs |
|---------|---------|------|
| `bubbletea` | TUI framework | [github.com/charmbracelet/bubbletea](https://github.com/charmbracelet/bubbletea) |
| `bubbles/list` | List component | [github.com/charmbracelet/bubbles](https://github.com/charmbracelet/bubbles) |
| `bubbles/textinput` | Text input component | Same as above |
| `lipgloss` | Styling | [github.com/charmbracelet/lipgloss](https://github.com/charmbracelet/lipgloss) |

## Common Issues

### "tmux: no server running"

tmux server isn't running. Create a session first:
```bash
tmux new-session -d -s test
```

### "exec format error"

Wrong binary architecture. Rebuild:
```bash
go build -o byosm ./cmd/byosm
```

### Terminal doesn't restore after crash

Reset terminal:
```bash
reset
# or
stty sane
```
