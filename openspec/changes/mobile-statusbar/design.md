## Context

Byoman creates byobu sessions via `internal/tmux/client.go`. Currently, sessions inherit byobu's default status bar configuration, which shows many widgets (hostname, date, time, memory, etc.) on the right side. This is too verbose for mobile screens.

Byobu's status bar is ultimately tmux's status bar. It can be configured:
1. Globally via `~/.byobu/status` and `~/.byobu/statusrc`
2. Per-session via `tmux set-option -t <session> status-right "..."`

## Goals / Non-Goals

**Goals:**
- All byoman-created sessions have a minimal status bar showing only CPU%
- Minimal disruption to existing code structure
- No changes to user's global byobu configuration

**Non-Goals:**
- User-configurable status bar contents (future: toggle option in TUI)
- Detecting mobile vs desktop context
- Modifying global byobu configuration files

## Decisions

### 1. Per-session configuration via tmux set-option

**Decision**: After creating a session, run `byobu set-option -t <session> status-right "<cpu>"` to override the status bar for that session only.

**Alternatives considered**:
- *Modify ~/.byobu/status*: Would affect all byobu sessions, not just byoman ones. Rejected.
- *Create separate byobu profile*: Too complex for current needs. Over-engineered.
- *Environment variable approach*: Byobu doesn't support session-specific config via env vars.

**Rationale**: Per-session tmux options are isolated, don't require file I/O, and are the standard way to customize individual sessions.

### 2. Status display format

**Decision**: Use `%H:%M %d-%b` for time and date display (e.g., "14:30 05-Feb").

**Rationale**: Simple tmux format string that works universally without external dependencies. Originally planned CPU% via `byobu-status cpu_percent` but it wasn't working reliably.

### 3. Implementation location

**Decision**: Add a `ConfigureMinimalStatusBar(sessionName string) error` method to the tmux client, called after `NewSession`.

**Rationale**: Keeps status bar logic separate from session creation. Easy to extend later with additional configuration.

### 4. Existing sessions (optional)

**Decision**: Add `ApplyMinimalStatusBar(sessionName string) error` that can be called on any session. Same implementation as above.

**Rationale**: Reuses the same logic. Can be wired up to a TUI action later.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Status bar changes may not persist across detach/reattach | Per-session tmux options do persist; verify in testing |
| User may want the full status bar back | Future: add toggle in byoman TUI (already in ideas.md) |
