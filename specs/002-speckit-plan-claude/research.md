# Research: tmux Session Manager

**Phase 0 Output** | **Date**: 2026-01-31

## Research Summary

| Topic | Decision | Rationale |
|-------|----------|-----------|
| TUI Framework | bubbletea + bubbles/list | Industry standard for Go TUIs, handles navigation automatically |
| tmux Interface | Format strings (-F flag) | Stable in 3.0+, enables structured parsing |
| Color Handling | lipgloss with AdaptiveColor | Automatic NO_COLOR respect, graceful degradation |
| CLI Structure | Cobra + dual-mode pattern | Subcommands, completions, TTY detection |
| Output Modes | TUI (default) + --json + --list | Supports interactive and scriptable use |

---

## 1. bubbletea Patterns

### Decision: Use bubbles/list for session list

**Rationale**: The `bubbles/list` component handles:
- Keyboard navigation (j/k, arrows) automatically
- Pagination for long lists
- Filtering support
- Help text generation

**Alternatives Considered**:
- Custom list implementation: More control but reinvents the wheel
- charmbracelet/huh: Better for forms, not list selection

### Model Structure

```go
type Model struct {
    list         list.Model      // bubbles/list handles navigation
    keys         KeyMap          // Custom keybindings via bubbles/key
    styles       Styles          // lipgloss styles
    
    mode         mode            // normal, confirm, input
    confirmTarget *Session       // Session pending kill/rename
    err          error
    quitting     bool
}

type mode int
const (
    modeNormal mode = iota
    modeConfirm
    modeInput
)
```

### Inline Confirmation Pattern

State-based approach for kill confirmation:

```go
func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    if m.mode == modeConfirm {
        switch msg := msg.(type) {
        case tea.KeyMsg:
            switch msg.String() {
            case "y", "Y":
                target := m.confirmTarget
                m.mode = modeNormal
                m.confirmTarget = nil
                return m, killSessionCmd(target.Name)
            case "n", "N", "esc":
                m.mode = modeNormal
                m.confirmTarget = nil
            }
        }
        return m, nil
    }
    // Normal handling...
}
```

### External State Handling

Use `tea.Tick` for periodic refresh:

```go
func tickCmd() tea.Cmd {
    return tea.Tick(2*time.Second, func(t time.Time) tea.Msg {
        return tickMsg(t)
    })
}
```

### Exiting for tmux attach

Use `tea.Quit` and handle attach in main after TUI exits:

```go
func main() {
    p := tea.NewProgram(initialModel())
    m, _ := p.Run()
    
    model := m.(Model)
    if model.selectedSession != nil {
        syscall.Exec("/usr/bin/tmux",
            []string{"tmux", "attach-session", "-t", model.selectedSession.Name},
            os.Environ())
    }
}
```

---

## 2. tmux Command Interface

### Decision: Use format strings for all data extraction

**Rationale**: Format strings (-F flag) provide:
- Structured, parseable output
- Stable interface in tmux 3.0+
- Access to all session metadata

### Session List Command

```bash
tmux list-sessions -F '#{session_name}|#{session_id}|#{session_created}|#{session_last_attached}|#{session_attached}|#{session_windows}'
```

**Format Variables Used**:
| Variable | Description | Example |
|----------|-------------|---------|
| `#{session_name}` | Session name | "dev" |
| `#{session_created}` | Unix timestamp created | 1738295560 |
| `#{session_last_attached}` | Unix timestamp last attached | 1738295800 |
| `#{session_attached}` | Attached client count (0=detached) | 1 |
| `#{session_windows}` | Window count | 3 |

### Pane Commands for Running Programs

```bash
tmux list-panes -s -t session_name -F '#{window_index}.#{pane_index}|#{pane_current_command}'
```

### Session Management Commands

| Action | Command |
|--------|---------|
| Attach | `tmux attach-session -t name` |
| Create | `tmux new-session -d -s name` |
| Rename | `tmux rename-session -t old new` |
| Kill | `tmux kill-session -t name` |
| Exists? | `tmux has-session -t name` (exit 0 if yes) |

### Version Detection

```bash
tmux -V | cut -d' ' -f2  # Returns "3.5a"
```

### Error Handling

| Error | tmux Message |
|-------|--------------|
| Not installed | Command not found (exit 127) |
| No server | "no server running on..." |
| Session not found | "can't find session: name" |
| Permission denied | "error connecting to... (Permission denied)" |

---

## 3. Color Handling

### Decision: Use lipgloss with AdaptiveColor

**Rationale**: 
- Automatic NO_COLOR environment variable respect via termenv
- Graceful degradation: TrueColor → ANSI256 → ANSI → Ascii
- Light/dark theme support with AdaptiveColor

### NO_COLOR Implementation

```go
var noColor = flag.Bool("no-color", false, "Disable colored output")

func initStyles() {
    if *noColor {
        lipgloss.SetColorProfile(termenv.Ascii)
    }
    // Styles work regardless - colors just become no-ops
}
```

### Style Definitions

```go
// colors.go
var (
    ColorPrimary = lipgloss.AdaptiveColor{Light: "57", Dark: "212"}
    ColorError   = lipgloss.AdaptiveColor{Light: "124", Dark: "196"}
    ColorSuccess = lipgloss.AdaptiveColor{Light: "22", Dark: "46"}
    ColorMuted   = lipgloss.AdaptiveColor{Light: "245", Dark: "241"}
)

// styles.go
var (
    StyleTitle    = lipgloss.NewStyle().Bold(true).Foreground(ColorPrimary)
    StyleSelected = lipgloss.NewStyle().Bold(true).Foreground(ColorSuccess)
    StyleError    = lipgloss.NewStyle().Bold(true).Foreground(ColorError)
)
```

---

## 4. CLI Structure

### Decision: Cobra + IOStreams pattern + dual-mode

**Rationale**:
- Cobra provides subcommands, completions, help generation
- IOStreams abstracts I/O for testability
- Dual-mode enables both interactive and scriptable use

### TTY Detection

```go
import "golang.org/x/term"

func isTTY() bool {
    return term.IsTerminal(int(os.Stdout.Fd())) &&
           term.IsTerminal(int(os.Stdin.Fd()))
}
```

### Mode Selection Logic

```go
func selectMode(flags Flags) OutputMode {
    if flags.JSON {
        return ModeJSON
    }
    if flags.List || !isTTY() {
        return ModeText
    }
    return ModeTUI
}
```

### Output Modes

| Mode | Flag | Trigger | Output |
|------|------|---------|--------|
| TUI | (default) | TTY detected | Interactive bubbletea UI |
| Text | `--list` | Non-TTY or explicit | Simple text list |
| JSON | `--json` | Explicit | Machine-readable JSON |

### JSON Output Structure

```go
type SessionOutput struct {
    Name         string `json:"name"`
    ID           string `json:"id"`
    Created      int64  `json:"created"`
    LastAttached int64  `json:"lastAttached,omitempty"`
    Attached     bool   `json:"attached"`
    WindowCount  int    `json:"windowCount"`
}
```

---

## 5. Resolved Design Needs

From Constitution Check:

| Need | Resolution |
|------|------------|
| Scriptable mode | `--list` for text, `--json` for machine-readable |
| Color handling | lipgloss auto-respects NO_COLOR; add `--no-color` flag |
| Stale session handling | 2-second tick refresh; graceful handling when session disappears |
| Centralized strings | `internal/strings/messages.go` with const block |
| Error format | Structured: `Error: {what}\nCause: {why}\nFix: {remediation}` |
| Logging | `internal/logging/` with debug flag; writes to ~/.byoman/logs/ |

---

## 6. Dependencies

```go
// go.mod
module github.com/byoman/tmux-manager

go 1.21

require (
    github.com/charmbracelet/bubbletea v0.25.0
    github.com/charmbracelet/bubbles v0.17.0
    github.com/charmbracelet/lipgloss v0.9.0
    github.com/spf13/cobra v1.8.0
    golang.org/x/term v0.15.0
)
```
