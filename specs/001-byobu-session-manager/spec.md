# Feature Specification: tmux Session Manager

**Feature Branch**: `001-byobu-session-manager`  
**Created**: 2026-01-30  
**Status**: Draft  
**Input**: User description: "CLI tool to manage tmux sessions with session listing, metrics display, and session actions"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View All Sessions (Priority: P1)

As a developer who uses multiple tmux sessions for different projects, I want to see a list of all my sessions so that I can quickly understand what's running and choose which session to work with.

**Why this priority**: This is the core functionality - without seeing sessions, no other actions are possible. Users need visibility into their sessions before they can manage them.

**Independent Test**: Can be fully tested by running the tool and verifying it displays all existing tmux sessions with their metrics. Delivers immediate value by providing session awareness.

**Acceptance Scenarios**:

1. **Given** multiple tmux sessions exist, **When** I run the tool, **Then** I see a list of all sessions with their names
2. **Given** sessions exist, **When** I view the list, **Then** I see session metrics (created time, last attached time, attached/detached status, window count, current commands)
3. **Given** no sessions exist, **When** I run the tool, **Then** I see a message indicating no sessions are available
4. **Given** sessions exist, **When** I view the list, **Then** the information is current (sourced directly from tmux)

---

### User Story 2 - Attach to Existing Session (Priority: P1)

As a developer returning to work, I want to easily attach to an existing session so that I can resume my work without remembering tmux command syntax.

**Why this priority**: Attaching to sessions is the primary use case after viewing them. This is the most common action users will perform.

**Independent Test**: Can be fully tested by selecting a session from the list and verifying successful attachment. Delivers immediate value by simplifying session reconnection.

**Acceptance Scenarios**:

1. **Given** I see a list of sessions, **When** I select a session to attach, **Then** I am attached to that session
2. **Given** I am attached to a different session, **When** I select another session, **Then** I am switched to the newly selected session
3. **Given** a session is already attached elsewhere, **When** I select it, **Then** I can still attach (tmux allows multiple attachments)

---

### User Story 3 - Start New Session (Priority: P2)

As a developer starting a new project, I want to create a new tmux session so that I can organize my work without leaving the interface.

**Why this priority**: Creating sessions is important but less frequent than viewing/attaching. Users can always create sessions via regular tmux commands if needed.

**Independent Test**: Can be fully tested by creating a new session and verifying it appears in the session list with correct initial state.

**Acceptance Scenarios**:

1. **Given** I am viewing the session list, **When** I choose to create a new session, **Then** a new tmux session is created
2. **Given** I create a new session, **When** I provide a name, **Then** the session is created with that name
3. **Given** I create a new session without a name, **When** the session is created, **Then** tmux assigns a default name
4. **Given** I create a new session with a name that already exists, **When** I submit, **Then** I see an error and am prompted to choose a different name

---

### User Story 4 - Rename Session (Priority: P3)

As a developer organizing my workspace, I want to rename a session so that I can better identify its purpose.

**Why this priority**: Renaming is a convenience feature that improves organization but isn't essential for basic session management.

**Independent Test**: Can be fully tested by renaming a session and verifying the new name appears in the session list.

**Acceptance Scenarios**:

1. **Given** I select a session, **When** I choose to rename it and provide a new name, **Then** the session is renamed
2. **Given** I rename a session, **When** I view the session list, **Then** I see the updated name
3. **Given** I rename a session to a name that already exists, **When** I submit, **Then** I see an error and am prompted to choose a different name

---

### User Story 5 - Kill Session (Priority: P3)

As a developer cleaning up my workspace, I want to terminate sessions I no longer need so that I can reduce clutter and free resources.

**Why this priority**: Killing sessions is destructive and less frequent. Users need this capability but it's not the primary workflow.

**Independent Test**: Can be fully tested by killing a session and verifying it no longer appears in the session list.

**Acceptance Scenarios**:

1. **Given** I select a session, **When** I choose to kill it, **Then** I see an inline confirmation prompt ("Kill session 'name'? [y/N]")
2. **Given** I see the kill confirmation prompt, **When** I press 'y', **Then** the session is terminated
3. **Given** I see the kill confirmation prompt, **When** I press 'n' or any other key, **Then** the action is cancelled and the session remains
4. **Given** I kill a session, **When** I view the session list, **Then** the killed session no longer appears

---

### Edge Cases

- What happens when tmux is not installed or version is below 3.0? Display a clear error message indicating the dependency and minimum version is required.
- What happens when the user has no permissions to access tmux sockets? Display an appropriate error message.
- What happens when a session is killed externally while viewing the list? Refresh the list or handle gracefully when attempting to act on a stale entry.
- What happens when session names contain special characters? Display them correctly without breaking the interface.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a list of all existing tmux sessions
- **FR-002**: System MUST show session name for each session
- **FR-003**: System MUST show session created time for each session
- **FR-004**: System MUST show last attached time for each session
- **FR-005**: System MUST show attached/detached status for each session
- **FR-006**: System MUST show number of windows for each session
- **FR-007**: System MUST show current running command per pane for each session
- **FR-008**: System MUST allow users to attach to a selected session
- **FR-009**: System MUST allow users to start a new session
- **FR-010**: System MUST allow users to rename a selected session
- **FR-011**: System MUST allow users to kill a selected session
- **FR-012**: System MUST source all session data directly from tmux (no config files or hidden state)
- **FR-013**: System MUST work on any system with tmux 3.0+ installed (no additional runtime dependencies; implemented in Go as single binary)
- **FR-015**: System MUST display inline confirmation prompt before killing a session
- **FR-016**: System MUST validate session name uniqueness and display error on collision during create/rename
- **FR-014**: System MUST provide keyboard navigation for session selection and actions

### Key Entities

- **Session**: A tmux session with attributes: name (unique identifier), created time, last attached time, attachment status, window count
- **Window**: A window within a session containing one or more panes
- **Pane**: A terminal pane within a window running a specific command

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view all sessions and their metrics within 2 seconds of launching the tool
- **SC-002**: Users can attach to any session with no more than 3 keystrokes/actions from the initial view
- **SC-003**: All displayed session information accurately reflects current tmux state (no stale data)
- **SC-004**: Tool launches and displays session list without requiring any configuration
- **SC-005**: Users can perform all core actions (view, attach, create, rename, kill) without referring to documentation after first use

## Assumptions

- Users have tmux 3.0 or later installed on their system (byobu users are supported as byobu wraps tmux)
- Users are comfortable with command-line interfaces
- The tool will use standard tmux commands to query session information (e.g., `tmux list-sessions`, `tmux display-message`)
- Session metrics will update each time the interface is refreshed rather than in real-time
- The interface will be text-based (TUI) suitable for terminal use

## Technical Constraints

- **Implementation Language**: Go (compiled single binary, no runtime dependencies)
- **TUI Framework**: bubbletea/lipgloss ecosystem for terminal UI
- **Minimum tmux Version**: 3.0+ (required for stable format string support)
- **Terminology**: "tmux" is the canonical term; tool works seamlessly with byobu installations

## Clarifications

### Session 2026-01-31

- Q: What implementation language should be used? → A: Go (single binary, bubbletea/lipgloss ecosystem)
- Q: How should kill confirmation work? → A: Inline yes/no prompt before kill action
- Q: What happens on session name collision during create/rename? → A: Show error, prompt for different name
- Q: What is the minimum tmux version required? → A: tmux 3.0+
- Q: Should "byobu" or "tmux" be the canonical term? → A: "tmux" (tool works with byobu seamlessly)
