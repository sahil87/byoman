# Quickstart: byoman - tmux Session Manager

## Prerequisites

- tmux 3.0+ installed (`tmux -V` to check)
- Go 1.21+ (for building from source)

## Installation

### From Source

```bash
# Clone the repository
git clone https://github.com/byoman/byoman.git
cd byoman

# Build
go build -o byoman ./cmd/byoman

# Install to PATH
sudo mv byoman /usr/local/bin/
```

### Verify Installation

```bash
byoman --version
# byoman v0.1.0
```

## Quick Usage

### Launch Interactive TUI

```bash
byoman
```

Use arrow keys or `j`/`k` to navigate, `Enter` to attach.

### List Sessions (for scripts)

```bash
byoman --list
```

### JSON Output

```bash
byoman --json | jq '.sessions[].name'
```

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `↑`/`k` | Move up |
| `↓`/`j` | Move down |
| `Enter` | Attach to session |
| `n` | New session |
| `r` | Rename session |
| `x` | Kill session |
| `q` | Quit |

## Shell Integration

Add to `~/.tmux.conf`:

```tmux
# Launch byoman with prefix + s
bind-key s run-shell "byoman"
```

Add to `~/.bashrc` or `~/.zshrc`:

```bash
alias bs="byoman"
```

## Troubleshooting

### "tmux not found"

Install tmux:
- macOS: `brew install tmux`
- Ubuntu/Debian: `sudo apt install tmux`
- Fedora: `sudo dnf install tmux`

### "tmux version below 3.0"

Upgrade tmux to 3.0+. byoman uses format strings that require tmux 3.0.

### Colors not showing

Check if `NO_COLOR` environment variable is set. To force colors:
```bash
unset NO_COLOR
byoman
```

## Project Structure

```
cmd/byoman/main.go     # Entry point
internal/
  tmux/                # tmux client and parsing
  tui/                 # bubbletea TUI
  strings/             # User-facing messages
```

## Development

```bash
# Run tests
go test ./...

# Run with race detector
go run -race ./cmd/byoman

# Build for multiple platforms
GOOS=linux GOARCH=amd64 go build -o byoman-linux ./cmd/byoman
GOOS=darwin GOARCH=arm64 go build -o byoman-mac ./cmd/byoman
```
