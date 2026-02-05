package tui

import (
	"byoman/internal/byobu"

	tea "github.com/charmbracelet/bubbletea"
)

// Update handles messages and updates the model.
func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		return m.handleKeyMsg(msg)

	case tea.WindowSizeMsg:
		m.list.SetSize(msg.Width, msg.Height-4)
		return m, nil

	case tickMsg:
		// Store selection before refresh
		if item, ok := m.list.SelectedItem().(sessionItem); ok {
			m.selectedName = item.session.Name
		}
		return m, tea.Batch(loadSessions(m.client), tickCmd())

	case sessionsLoadedMsg:
		if msg.err != nil {
			m.err = msg.err
			return m, nil
		}
		m.updateSessionsPreserveSelection(msg.sessions)
		return m, nil

	case sessionActionMsg:
		if msg.err != nil {
			m.err = msg.err
		}
		// Refresh after action
		return m, loadSessions(m.client)
	}

	var cmd tea.Cmd
	m.list, cmd = m.list.Update(msg)
	return m, cmd
}

func (m Model) handleKeyMsg(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	// Clear any error on keypress
	m.err = nil

	// Handle based on current state
	switch m.state {
	case StateConfirmKill:
		return m.handleConfirmKill(msg)
	case StateNewSession:
		return m.handleNewSession(msg)
	case StateRenameSession:
		return m.handleRenameSession(msg)
	default:
		return m.handleListState(msg)
	}
}

func (m Model) handleListState(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "q", "ctrl+c":
		m.quitting = true
		return m, tea.Quit

	case "enter":
		if session, ok := m.currentSession(); ok {
			m.selectedSession = session.Name
			m.quitting = true
			return m, tea.Quit
		}

	case "n":
		m.state = StateNewSession
		m.textInput.Reset()
		m.textInput.Placeholder = "session name"
		m.textInput.Focus()
		return m, nil

	case "r":
		if session, ok := m.currentSession(); ok {
			m.state = StateRenameSession
			m.textInput.Reset()
			m.textInput.SetValue(session.Name)
			m.textInput.Focus()
			return m, nil
		}

	case "k":
		if session, ok := m.currentSession(); ok {
			m.state = StateConfirmKill
			m.confirmTarget = session.Name
			return m, nil
		}
	}

	var cmd tea.Cmd
	m.list, cmd = m.list.Update(msg)
	return m, cmd
}

func (m Model) handleConfirmKill(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "y", "Y":
		name := m.confirmTarget
		m.state = StateList
		m.confirmTarget = ""
		return m, killSession(m.client, name)
	default:
		// Any other key cancels
		m.state = StateList
		m.confirmTarget = ""
		return m, nil
	}
}

func (m Model) handleNewSession(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "enter":
		name := m.textInput.Value()
		m.state = StateList
		m.textInput.Blur()
		return m, newSession(m.client, name)
	case "esc":
		m.state = StateList
		m.textInput.Blur()
		return m, nil
	}

	var cmd tea.Cmd
	m.textInput, cmd = m.textInput.Update(msg)
	return m, cmd
}

func (m Model) handleRenameSession(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "enter":
		if session, ok := m.currentSession(); ok {
			newName := m.textInput.Value()
			m.state = StateList
			m.textInput.Blur()
			return m, renameSession(m.client, session.Name, newName)
		}
		m.state = StateList
		return m, nil
	case "esc":
		m.state = StateList
		m.textInput.Blur()
		return m, nil
	}

	var cmd tea.Cmd
	m.textInput, cmd = m.textInput.Update(msg)
	return m, cmd
}

func killSession(client byobu.Client, name string) tea.Cmd {
	return func() tea.Msg {
		err := client.KillSession(name)
		return sessionActionMsg{err: err}
	}
}

func newSession(client byobu.Client, name string) tea.Cmd {
	return func() tea.Msg {
		err := client.NewSession(name)
		if err != nil {
			return sessionActionMsg{err: err}
		}
		// Configure minimal status bar for the new session
		// Log warning but don't fail if status bar config fails
		if sbErr := client.ConfigureMinimalStatusBar(name); sbErr != nil {
			// Status bar config is best-effort, don't fail the session creation
			_ = sbErr
		}
		return sessionActionMsg{err: nil}
	}
}

func renameSession(client byobu.Client, oldName, newName string) tea.Cmd {
	return func() tea.Msg {
		err := client.RenameSession(oldName, newName)
		return sessionActionMsg{err: err}
	}
}
