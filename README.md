# BYOMAN

A manager for byobu sessions

## Motivation

Byobu was created because tmux commands are tough to remember. Byobu simplifed the shortcuts and made tmux easier to use.
However even Byobu sufferes from some problems:
* The command line options to choose from an older Byobu session is tough to remember
* There's no central interface to manage all sessions

## What are we building

A command line program (or shell script) that shows you an interface which lists all byobu sessions.

### Session Metrics

The interface should display useful metrics for each session (all sourced directly from tmux):
* Session name
* Created time
* Last attached time
* Attached/detached status
* Number of windows
* Current running command (per pane)

### Actions

There should be an easy way to:
* Start a new session
* Attach to an existing session
* Rename a session
* Kill a session

## Design Principles

- Pure tmux wrapper - no config files or hidden state
- All session data comes directly from tmux
- Works immediately on any system with tmux installed

## Who is this for?

If you use remote sessions a lot for development and use byobu (or want to) for long running sessions, this tool is for you.

## Installation

### Quick install (macOS/Linux)

```bash
curl -sSfL https://raw.githubusercontent.com/sahil87/byoman/main/install.sh | sh
```

### Go install

```bash
go install github.com/sahil87/byoman@latest
```

### Manual download

Download the appropriate binary from the [releases page](https://github.com/sahil87/byoman/releases).

## Getting Started

### Prerequisites

- tmux installed (byobu runs on tmux)
- byobu installed (optional, but recommended for the intended workflow)

### Run from source

```bash
go mod download
go run .
```

### Build from source

```bash
go build -o byoman .
./byoman
```

## Usage

- Use arrow keys to move through sessions
- Press `enter` to attach to the selected session
- Press `n` to create a new session
- Press `r` to rename the selected session
- Press `k` to kill the selected session, then `y` to confirm
- Press `esc` to cancel a rename/new session prompt
- Press `q` (or `ctrl+c`) to quit
