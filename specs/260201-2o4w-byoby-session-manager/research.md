# Research: tmux Session Manager

**Branch**: `260201-2o4w-byoby-session-manager` | **Date**: 2026-02-01

## 1. tmux Session Metrics via CLI

### Decision
Use `tmux list-sessions`, `list-windows`, and `list-panes` with custom format strings and tab delimiters for easy Go parsing.

### Rationale
tmux 3.0+ provides stable format string support. Tab-delimited output parses cleanly with `strings.Split`. Unix timestamps allow precise time calculations without locale issues.

### Alternatives Considered
- **JSON output**: tmux doesn't support native JSON; would require custom formatting
- **Human-readable time format (`#{t:...}`)**: Harder to parse, locale-dependent

### Commands & Format Strings

**Session info:**
```bash
tmux list-sessions -F '#{session_name}\t#{session_created}\t#{session_last_attached}\t#{session_attached}\t#{session_windows}\t#{session_id}'
```

| Variable | Type | Description |
|----------|------|-------------|
| `session_name` | string | Session name (unique identifier) |
| `session_created` | int64 | Unix timestamp when created |
| `session_last_attached` | int64 | Unix timestamp of last attachment |
| `session_attached` | int | Number of clients attached (0 = detached) |
| `session_windows` | int | Number of windows |
| `session_id` | string | Unique ID (prefixed with `$`) |

**Pane info (for running commands):**
```bash
tmux list-panes -a -F '#{session_name}\t#{window_index}\t#{pane_index}\t#{pane_current_command}\t#{pane_current_path}'
```

| Variable | Type | Description |
|----------|------|-------------|
| `pane_current_command` | string | Foreground process (e.g., `vim`, `zsh`) |
| `pane_current_path` | string | Current working directory |

**No server handling:**
```go
if strings.Contains(err.Error(), "no server") {
    return nil, nil // No sessions, not an error
}
```

---

## 2. Bubbletea List with Auto-Refresh

### Decision
Use `bubbles/list` component with `tea.Tick` for 3-second refresh intervals. Preserve selection by session name (not index).

### Rationale
- `bubbles/list` provides built-in navigation, filtering, and pagination
- `tea.Tick` sends single message; loop by returning another tick command
- Selection by name survives session additions/deletions during refresh

### Alternatives Considered
- **Custom list**: More control but reinvents navigation/scrolling
- **`tea.Every`**: Aligns to clock boundaries, not what we want
- **Selection by index**: Breaks when list order changes

### Pattern

```go
type tickMsg time.Time

func tickCmd() tea.Cmd {
    return tea.Tick(3*time.Second, func(t time.Time) tea.Msg {
        return tickMsg(t)
    })
}

func (m model) Init() tea.Cmd {
    return tea.Batch(m.loadSessions(), tickCmd())
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tickMsg:
        // Store selection before refresh
        if item, ok := m.list.SelectedItem().(Session); ok {
            m.selectedName = item.Name
        }
        return m, tea.Batch(m.loadSessions(), tickCmd())

    case sessionsLoadedMsg:
        m.updateSessionsPreserveSelection(msg.sessions)
        return m, nil
    }
    // ...
}

func (m *model) updateSessionsPreserveSelection(sessions []Session) {
    items := make([]list.Item, len(sessions))
    for i, s := range sessions {
        items[i] = s
    }
    m.list.SetItems(items)

    // Restore selection by name
    for i, s := range sessions {
        if s.Name == m.selectedName {
            m.list.Select(i)
            return
        }
    }
}
```

**Key insight**: Input is never blocked during refresh—bubbletea runs commands in goroutines.

---

## 3. Terminal Handoff to tmux Attach

### Decision
Use `syscall.Exec` after `tea.Quit` to replace the Go process with tmux. Store selected session in model, exec after `Run()` returns.

### Rationale
- User expects to be "in tmux" after selection, not return to TUI after detach
- `syscall.Exec` completely replaces the process (Go binary ceases to exist)
- Clean terminal state guaranteed—bubbletea restores terminal before `Run()` returns

### Alternatives Considered
- **`tea.ExecProcess`**: Pauses TUI, runs command, resumes after—not desired UX
- **`exec.Command` with Wait**: Leaves Go process running, uses more memory

### Pattern

```go
type model struct {
    sessions        []Session
    cursor          int
    selectedSession string // Populated when user presses Enter
    quitting        bool
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        switch msg.String() {
        case "enter":
            m.selectedSession = m.sessions[m.cursor].Name
            m.quitting = true
            return m, tea.Quit
        }
    }
    return m, nil
}

func (m model) View() string {
    if m.quitting {
        return "" // Prevent terminal artifacts
    }
    // ... render list
}

func main() {
    p := tea.NewProgram(initialModel)
    finalModel, _ := p.Run()

    m := finalModel.(model)
    if m.selectedSession != "" {
        execTmuxAttach(m.selectedSession)
    }
}

func execTmuxAttach(sessionName string) {
    binary, _ := exec.LookPath("tmux")
    args := []string{"tmux", "attach-session", "-t", sessionName}
    syscall.Exec(binary, args, os.Environ())
    // Never returns on success
}
```

---

## 4. Inline Confirmation Prompts

### Decision
Use state flag in main model with enum for confirmation type. Any key except `y`/`Y` cancels (safer UX).

### Rationale
- Simple y/n confirmations don't warrant a separate component
- State in main model keeps code straightforward
- "Any key cancels" is safer than requiring explicit `n`

### Alternatives Considered
- **Separate confirmation component**: Overkill for single-key response
- **Full modal overlay**: Too heavy for inline prompt
- **Only `n` cancels**: Risk of accidental confirmation

### Pattern

```go
type confirmState int

const (
    confirmNone confirmState = iota
    confirmKill
)

type model struct {
    sessions      []Session
    cursor        int
    confirmState  confirmState
    confirmTarget string
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        // Handle confirmation mode first
        if m.confirmState != confirmNone {
            return m.handleConfirmation(msg)
        }

        switch msg.String() {
        case "k":
            if len(m.sessions) > 0 {
                m.confirmState = confirmKill
                m.confirmTarget = m.sessions[m.cursor].Name
            }
        }
    }
    return m, nil
}

func (m model) handleConfirmation(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
    switch msg.String() {
    case "y", "Y":
        name := m.confirmTarget
        m.confirmState = confirmNone
        m.confirmTarget = ""
        return m, killSession(name)
    default:
        // Any other key cancels
        m.confirmState = confirmNone
        m.confirmTarget = ""
    }
    return m, nil
}

func (m model) View() string {
    // ... render list

    if m.confirmState == confirmKill {
        style := lipgloss.NewStyle().Foreground(lipgloss.Color("205")).Bold(true)
        return listView + "\n" + style.Render(
            fmt.Sprintf("Kill session '%s'? [y/N] ", m.confirmTarget),
        )
    }
    return listView + "\n[n]ew  [r]ename  [k]ill  [q]uit"
}
```

---

## Sources

- [tmux Formats Wiki](https://github.com/tmux/tmux/wiki/Formats)
- [tmux(1) Manual](https://man7.org/linux/man-pages/man1/tmux.1.html)
- [Bubbletea GitHub](https://github.com/charmbracelet/bubbletea)
- [Bubbles List Component](https://github.com/charmbracelet/bubbles/tree/master/list)
- [Bubbletea Commands](https://charm.land/blog/commands-in-bubbletea/)
- [Go by Example: Exec'ing Processes](https://gobyexample.com/execing-processes)
- [Bubbletea exec.go](https://github.com/charmbracelet/bubbletea/blob/main/exec.go)
