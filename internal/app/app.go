package app

import (
	"byosm/internal/tmux"
	"byosm/internal/tui"
	"fmt"
	"os"
	"syscall"

	tea "github.com/charmbracelet/bubbletea"
)

// Run starts the TUI application.
// It returns the name of the session to attach to (if any).
func Run() error {
	// Check tmux is installed and version is adequate
	if err := tmux.CheckVersion(); err != nil {
		return err
	}

	client := tmux.NewClient()
	model := tui.NewModel(client)

	p := tea.NewProgram(model, tea.WithAltScreen())
	finalModel, err := p.Run()
	if err != nil {
		return fmt.Errorf("error running program: %w", err)
	}

	// Check if user selected a session to attach
	m := finalModel.(tui.Model)
	if sessionName := m.SelectedSession(); sessionName != "" {
		return attachToSession(client, sessionName)
	}

	return nil
}

// attachToSession replaces the current process with tmux attach.
func attachToSession(client *tmux.DefaultClient, name string) error {
	binary, args, err := client.AttachSessionArgs(name)
	if err != nil {
		return err
	}

	// syscall.Exec replaces the current process
	return syscall.Exec(binary, args, os.Environ())
}
