# Feature Specification: Byobu Sessions

**Feature Branch**: `260202-2gdn-byobu-sessions`
**Created**: 2026-02-02
**Status**: Draft
**Input**: User description: "Right now byoman starts tmux sessions. But I want it explicitly start byobu sessions."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Start Byobu Sessions (Priority: P1)

As a byobu user, I want byoman to create byobu sessions instead of tmux sessions, so that my new sessions automatically include byobu's keybindings, status bar, and configuration.

**Why this priority**: This is the core feature request. Users choose byobu specifically for its enhanced UX (status bar, keybindings, profiles), and sessions created via raw tmux bypass these features.

**Independent Test**: Can be verified by creating a new session through byoman and confirming it has byobu's status bar and keybindings active.

**Acceptance Scenarios**:

1. **Given** byobu is installed on the system, **When** user creates a new session via byoman, **Then** the session is created using byobu and includes byobu's status bar and keybindings
2. **Given** user has existing byobu profile configurations, **When** user creates a new session via byoman, **Then** the new session respects those profile settings

---

### User Story 2 - Attach to Byobu Sessions (Priority: P1)

As a byobu user, I want byoman to attach to sessions using byobu, so that I get byobu's enhanced attachment experience.

**Why this priority**: Attachment is equally critical as creation - users need the full byobu experience when connecting to sessions.

**Independent Test**: Can be verified by selecting a session in byoman and confirming the attachment uses byobu with its full feature set.

**Acceptance Scenarios**:

1. **Given** a byobu session exists, **When** user selects it in byoman and presses enter, **Then** byoman attaches using byobu
2. **Given** user attaches via byoman, **When** in the session, **Then** byobu keybindings and status bar are available

---

### User Story 3 - Graceful Fallback When Byobu Unavailable (Priority: P2)

As a user who may not have byobu installed, I want byoman to provide a clear error message if byobu is missing, so I know what action to take.

**Why this priority**: Users should understand why byoman won't work without byobu, rather than getting cryptic errors.

**Independent Test**: Can be verified by running byoman on a system without byobu installed and checking for a helpful error message.

**Acceptance Scenarios**:

1. **Given** byobu is not installed, **When** user launches byoman, **Then** a clear error message is displayed explaining byobu is required
2. **Given** byobu is installed but too old, **When** user launches byoman, **Then** a clear error message indicates the minimum required version

---

### Edge Cases

- What happens when byobu is installed but underlying tmux is missing? Byobu requires tmux, so byobu's own error handling should apply.
- What happens when user has custom byobu configuration that conflicts with byoman operations? Normal byobu behavior should apply - byoman does not override byobu config.
- What happens when migrating existing tmux sessions to byobu? Existing sessions remain accessible (byobu can list and attach to tmux sessions).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST use byobu commands for all session operations (create, list, attach, rename, kill)
- **FR-002**: System MUST verify byobu is installed and accessible before performing operations
- **FR-003**: System MUST provide clear error messages when byobu is unavailable or incompatible
- **FR-004**: System MUST create sessions that include byobu's full feature set (status bar, keybindings, profiles)
- **FR-005**: System MUST be able to list and manage sessions created by byobu directly (not just via byoman)
- **FR-006**: System MUST preserve all existing functionality (list, create, rename, kill, attach sessions)

### Assumptions

- Users who want byobu sessions have byobu installed on their system
- Byobu's underlying tmux version requirements are sufficient for byoman's needs (byobu handles tmux version compatibility)
- Existing tmux sessions created before this change remain accessible (byobu wraps tmux and can see tmux sessions)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: New sessions created by byoman display byobu's status bar immediately upon creation
- **SC-002**: Byobu keybindings (F1-F12 help, F2 new window, etc.) work in byoman-created sessions
- **SC-003**: User's byobu profile settings are applied to byoman-created sessions
- **SC-004**: All existing byoman operations (list, rename, kill, attach) continue to function correctly
- **SC-005**: Error messages for missing byobu are actionable (tell user how to install byobu)
