package byobu

import (
	"bytes"
	"fmt"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

// Client provides methods to interact with byobu.
type Client interface {
	ListSessions() ([]Session, error)
	GetPaneCommands() (map[string][]string, error)
	NewSession(name string) error
	RenameSession(oldName, newName string) error
	KillSession(name string) error
	AttachSessionArgs(name string) (binary string, args []string, err error)
	ConfigureMinimalStatusBar(sessionName string) error
}

// DefaultClient implements Client using os/exec.
type DefaultClient struct{}

// NewClient creates a new byobu client.
func NewClient() *DefaultClient {
	return &DefaultClient{}
}

// CheckVersion verifies byobu is installed.
// Returns nil if OK, error otherwise.
func CheckVersion() error {
	_, err := exec.LookPath("byobu")
	if err != nil {
		return fmt.Errorf("byobu is not installed.\n\nInstall with:\n  macOS:   brew install byobu\n  Ubuntu:  sudo apt install byobu\n  Fedora:  sudo dnf install byobu")
	}
	return nil
}

// ListSessions returns all byobu sessions.
func (c *DefaultClient) ListSessions() ([]Session, error) {
	format := "#{session_name}\t#{session_id}\t#{session_created}\t#{session_last_attached}\t#{session_attached}\t#{session_windows}"
	cmd := exec.Command("byobu", "list-sessions", "-F", format)

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	if err != nil {
		errMsg := stderr.String()
		if strings.Contains(errMsg, "no server running") {
			return nil, nil // No sessions, not an error
		}
		return nil, fmt.Errorf("byobu list-sessions: %s", strings.TrimSpace(errMsg))
	}

	output := strings.TrimSpace(stdout.String())
	if output == "" {
		return nil, nil
	}

	lines := strings.Split(output, "\n")
	sessions := make([]Session, 0, len(lines))

	for _, line := range lines {
		parts := strings.Split(line, "\t")
		if len(parts) < 6 {
			continue
		}

		created, _ := strconv.ParseInt(parts[2], 10, 64)
		lastAttached, _ := strconv.ParseInt(parts[3], 10, 64)
		attached, _ := strconv.Atoi(parts[4])
		windowCount, _ := strconv.Atoi(parts[5])

		sessions = append(sessions, Session{
			Name:         parts[0],
			ID:           parts[1],
			Created:      time.Unix(created, 0),
			LastAttached: time.Unix(lastAttached, 0),
			Attached:     attached,
			WindowCount:  windowCount,
		})
	}

	return sessions, nil
}

// GetPaneCommands returns running commands for all sessions.
// Map key is session name, value is list of unique commands.
func (c *DefaultClient) GetPaneCommands() (map[string][]string, error) {
	format := "#{session_name}\t#{pane_current_command}"
	cmd := exec.Command("byobu", "list-panes", "-a", "-F", format)

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	if err != nil {
		errMsg := stderr.String()
		if strings.Contains(errMsg, "no server running") {
			return nil, nil
		}
		return nil, fmt.Errorf("byobu list-panes: %s", strings.TrimSpace(errMsg))
	}

	output := strings.TrimSpace(stdout.String())
	if output == "" {
		return nil, nil
	}

	result := make(map[string][]string)
	seen := make(map[string]map[string]bool) // session -> commands seen

	lines := strings.Split(output, "\n")
	for _, line := range lines {
		parts := strings.Split(line, "\t")
		if len(parts) < 2 {
			continue
		}
		sessionName := parts[0]
		command := parts[1]

		if seen[sessionName] == nil {
			seen[sessionName] = make(map[string]bool)
		}
		if !seen[sessionName][command] {
			seen[sessionName][command] = true
			result[sessionName] = append(result[sessionName], command)
		}
	}

	return result, nil
}

// NewSession creates a new detached byobu session.
func (c *DefaultClient) NewSession(name string) error {
	args := []string{"new-session", "-d"}
	if name != "" {
		args = append(args, "-s", name)
	}

	cmd := exec.Command("byobu", args...)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr

	if err := cmd.Run(); err != nil {
		errMsg := strings.TrimSpace(stderr.String())
		if strings.Contains(errMsg, "duplicate session") {
			return fmt.Errorf("session '%s' already exists", name)
		}
		return fmt.Errorf("byobu new-session: %s", errMsg)
	}
	return nil
}

// RenameSession renames an existing session.
func (c *DefaultClient) RenameSession(oldName, newName string) error {
	if newName == "" {
		return fmt.Errorf("session name cannot be empty")
	}

	cmd := exec.Command("byobu", "rename-session", "-t", oldName, newName)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr

	if err := cmd.Run(); err != nil {
		errMsg := strings.TrimSpace(stderr.String())
		if strings.Contains(errMsg, "duplicate session") {
			return fmt.Errorf("session '%s' already exists", newName)
		}
		if strings.Contains(errMsg, "can't find session") || strings.Contains(errMsg, "session not found") {
			return fmt.Errorf("session '%s' not found", oldName)
		}
		return fmt.Errorf("byobu rename-session: %s", errMsg)
	}
	return nil
}

// KillSession terminates a session.
func (c *DefaultClient) KillSession(name string) error {
	cmd := exec.Command("byobu", "kill-session", "-t", name)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr

	if err := cmd.Run(); err != nil {
		errMsg := strings.TrimSpace(stderr.String())
		if strings.Contains(errMsg, "can't find session") || strings.Contains(errMsg, "session not found") {
			return fmt.Errorf("session '%s' not found", name)
		}
		return fmt.Errorf("byobu kill-session: %s", errMsg)
	}
	return nil
}

// AttachSessionArgs returns the command to attach to a session.
// Caller should use syscall.Exec with these args.
func (c *DefaultClient) AttachSessionArgs(name string) (binary string, args []string, err error) {
	binary, err = exec.LookPath("byobu")
	if err != nil {
		return "", nil, fmt.Errorf("byobu not found: %w", err)
	}
	args = []string{"byobu", "attach-session", "-t", name}
	return binary, args, nil
}

// ConfigureMinimalStatusBar sets a minimal status bar (date/time only) for a session.
// This applies per-session configuration without modifying global byobu settings.
func (c *DefaultClient) ConfigureMinimalStatusBar(sessionName string) error {
	// Minimal status: just date and time
	statusRight := "%H:%M %d-%b"

	cmd := exec.Command("byobu", "set-option", "-t", sessionName, "status-right", statusRight)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr

	if err := cmd.Run(); err != nil {
		errMsg := strings.TrimSpace(stderr.String())
		if strings.Contains(errMsg, "can't find session") || strings.Contains(errMsg, "session not found") {
			return fmt.Errorf("session '%s' not found", sessionName)
		}
		return fmt.Errorf("byobu set-option: %s", errMsg)
	}
	return nil
}
