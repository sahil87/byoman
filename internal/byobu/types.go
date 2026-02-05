package byobu

import "time"

// Session represents a byobu session.
type Session struct {
	Name         string    // Unique identifier (byobu session name)
	ID           string    // Internal session ID (e.g., "$0")
	Created      time.Time // When session was created
	LastAttached time.Time // Last time a client attached
	Attached     int       // Number of attached clients (0 = detached)
	WindowCount  int       // Number of windows in session
	Windows      []Window  // Window details (optional, loaded on demand)
	Commands     []string  // Running commands across all panes
}

// IsDetached returns true if no clients are attached.
func (s Session) IsDetached() bool {
	return s.Attached == 0
}

// Status returns "attached" or "detached" string.
func (s Session) Status() string {
	if s.Attached > 0 {
		return "attached"
	}
	return "detached"
}

// Window represents a window within a session.
type Window struct {
	Index     int    // Window index within session (0-based)
	Name      string // Window name
	ID        string // Internal window ID (e.g., "@0")
	PaneCount int    // Number of panes
	Active    bool   // Is this the active window?
	Panes     []Pane // Pane details
}

// Pane represents a terminal pane within a window.
type Pane struct {
	Index          int    // Pane index within window (0-based)
	ID             string // Internal pane ID (e.g., "%0")
	CurrentCommand string // Foreground process (e.g., "vim", "zsh")
	CurrentPath    string // Working directory
	Active         bool   // Is this the active pane?
}
