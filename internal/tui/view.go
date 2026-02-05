package tui

import (
	"fmt"
	"strings"
)

// View renders the current state.
func (m Model) View() string {
	if m.quitting {
		return "" // Prevent terminal artifacts
	}

	var b strings.Builder

	switch m.state {
	case StateConfirmKill:
		b.WriteString(m.renderList())
		b.WriteString("\n")
		b.WriteString(PromptStyle.Render(fmt.Sprintf("Kill session '%s'? [y/N] ", m.confirmTarget)))

	case StateNewSession:
		b.WriteString(TitleStyle.Render("New session"))
		b.WriteString("\n\n")
		b.WriteString(fmt.Sprintf("Session name: %s", m.textInput.View()))
		b.WriteString("\n\n")
		b.WriteString(HelpStyle.Render("[Enter] create  [Esc] cancel"))

	case StateRenameSession:
		if session, ok := m.currentSession(); ok {
			b.WriteString(TitleStyle.Render(fmt.Sprintf("Rename '%s'", session.Name)))
		} else {
			b.WriteString(TitleStyle.Render("Rename session"))
		}
		b.WriteString("\n\n")
		b.WriteString(fmt.Sprintf("New name: %s", m.textInput.View()))
		b.WriteString("\n\n")
		b.WriteString(HelpStyle.Render("[Enter] rename  [Esc] cancel"))

	default:
		b.WriteString(m.renderList())
		b.WriteString("\n")
		b.WriteString(m.renderHelp())
	}

	// Show error if any
	if m.err != nil {
		b.WriteString("\n")
		b.WriteString(ErrorStyle.Render(fmt.Sprintf("Error: %s", m.err.Error())))
	}

	return b.String()
}

func (m Model) renderList() string {
	if len(m.sessions) == 0 {
		return TitleStyle.Render("byobu sessions") + "\n\n" +
			DimStyle.Render("No byobu sessions. Press 'n' to create one.")
	}

	var b strings.Builder
	b.WriteString(TitleStyle.Render("byobu sessions"))
	b.WriteString("\n\n")

	for i, session := range m.sessions {
		cursor := "  "
		if i == m.list.Index() {
			cursor = CursorStyle.Render("> ")
		}

		name := session.Name
		if i == m.list.Index() {
			name = SelectedItemStyle.Render(name)
		}

		// Format: cursor name    windows  (status)  commands
		windowWord := "windows"
		if session.WindowCount == 1 {
			windowWord = "window"
		}
		windows := DimStyle.Render(fmt.Sprintf("%d %s", session.WindowCount, windowWord))

		var status string
		if session.Attached > 0 {
			status = AttachedStyle.Render("(attached)")
		} else {
			status = DetachedStyle.Render("(detached)")
		}

		var commands string
		if len(session.Commands) > 0 {
			commands = DimStyle.Render(strings.Join(session.Commands, ", "))
		}

		line := fmt.Sprintf("%s%-12s  %s  %s", cursor, name, windows, status)
		if commands != "" {
			line += "  " + commands
		}
		b.WriteString(line)
		b.WriteString("\n")
	}

	return b.String()
}

func (m Model) renderHelp() string {
	return HelpStyle.Render("[n]ew  [r]ename  [k]ill  [enter]attach  [q]uit")
}
