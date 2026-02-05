package tui

import (
	"byoman/internal/byobu"
	"time"

	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
)

// ViewState represents the current UI state.
type ViewState int

const (
	StateList ViewState = iota
	StateConfirmKill
	StateNewSession
	StateRenameSession
)

// refreshInterval is the auto-refresh period.
const refreshInterval = 3 * time.Second

// Model is the main bubbletea model.
type Model struct {
	// Data
	sessions []byobu.Session
	client   byobu.Client

	// UI State
	list         list.Model
	state        ViewState
	selectedName string // Preserved during refresh

	// Confirmation state
	confirmTarget string

	// Input state (for new/rename)
	textInput textinput.Model

	// Output
	selectedSession string // Populated on Enter, triggers attach
	quitting        bool
	err             error
	errExpiry       time.Time // When to clear the error
}

// sessionItem wraps Session for list.Item interface.
type sessionItem struct {
	session byobu.Session
}

func (i sessionItem) Title() string       { return i.session.Name }
func (i sessionItem) Description() string { return "" }
func (i sessionItem) FilterValue() string { return i.session.Name }

// NewModel creates a new TUI model.
func NewModel(client byobu.Client) Model {
	// Create list with custom delegate
	delegate := list.NewDefaultDelegate()
	delegate.ShowDescription = false

	l := list.New([]list.Item{}, delegate, 80, 20)
	l.Title = "byobu sessions"
	l.SetShowStatusBar(false)
	l.SetFilteringEnabled(false)
	l.SetShowHelp(false)
	l.Styles.Title = TitleStyle

	// Create text input for new/rename
	ti := textinput.New()
	ti.Placeholder = "session name"
	ti.CharLimit = 64

	return Model{
		client:    client,
		list:      l,
		state:     StateList,
		textInput: ti,
	}
}

// Init initializes the model.
func (m Model) Init() tea.Cmd {
	return tea.Batch(loadSessions(m.client), tickCmd())
}

// SelectedSession returns the session name to attach to (if any).
func (m Model) SelectedSession() string {
	return m.selectedSession
}

// tickMsg triggers a refresh.
type tickMsg time.Time

// sessionsLoadedMsg contains loaded sessions.
type sessionsLoadedMsg struct {
	sessions []byobu.Session
	err      error
}

// sessionActionMsg is the result of a session action (new/rename/kill).
type sessionActionMsg struct {
	err error
}

func tickCmd() tea.Cmd {
	return tea.Tick(refreshInterval, func(t time.Time) tea.Msg {
		return tickMsg(t)
	})
}

func loadSessions(client byobu.Client) tea.Cmd {
	return func() tea.Msg {
		sessions, err := client.ListSessions()
		if err != nil {
			return sessionsLoadedMsg{err: err}
		}

		// Load commands for each session
		commands, _ := client.GetPaneCommands()
		for i := range sessions {
			if cmds, ok := commands[sessions[i].Name]; ok {
				sessions[i].Commands = cmds
			}
		}

		return sessionsLoadedMsg{sessions: sessions}
	}
}

func (m *Model) updateSessionsPreserveSelection(sessions []byobu.Session) {
	m.sessions = sessions

	items := make([]list.Item, len(sessions))
	for i, s := range sessions {
		items[i] = sessionItem{session: s}
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

func (m Model) currentSession() (byobu.Session, bool) {
	if item, ok := m.list.SelectedItem().(sessionItem); ok {
		return item.session, true
	}
	return byobu.Session{}, false
}
