## ADDED Requirements

### Requirement: Minimal status bar for new sessions
The system SHALL configure a minimal status bar for all byobu sessions created via byoman. The minimal status bar SHALL display only CPU usage percentage on the right side.

#### Scenario: New session gets minimal status bar
- **WHEN** a user creates a new byobu session via byoman
- **THEN** the session's right status bar displays only CPU%
- **AND** the left status bar remains unchanged

#### Scenario: Status bar persists across detach/reattach
- **WHEN** a user detaches from a byoman-created session and reattaches
- **THEN** the minimal status bar configuration is preserved

### Requirement: Minimal status bar for existing sessions
The system SHALL provide a mechanism to apply the minimal status bar configuration to existing byobu sessions.

#### Scenario: Apply minimal status bar to existing session
- **WHEN** the minimal status bar configuration is applied to an existing session
- **THEN** the session's right status bar changes to display only CPU%
- **AND** the session continues running without interruption

### Requirement: No global configuration changes
The system SHALL NOT modify the user's global byobu configuration files. All status bar changes SHALL be applied per-session only.

#### Scenario: Global config unchanged after session creation
- **WHEN** byoman creates a session with minimal status bar
- **THEN** the user's ~/.byobu/status file is not modified
- **AND** the user's ~/.byobu/statusrc file is not modified
- **AND** other byobu sessions (not created by byoman) retain their original status bar
