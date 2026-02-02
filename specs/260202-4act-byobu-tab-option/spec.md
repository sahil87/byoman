# Feature Specification: Byobu Tab Option

**Feature Branch**: `260202-4act-byobu-tab-option`  
**Created**: 2026-02-02  
**Status**: Draft  
**Input**: User description: "In wt-create also give option to open the worktree as a byobu tab (assuming wt-create was called inside a byobu session) along with the other options"

## Clarifications

### Session 2026-02-02

- Q: Should the new byobu tab be focused immediately or created in the background? → A: Focus new tab immediately.
- Q: Which naming behavior should the new byobu tab use? → A: Use repo name + worktree name.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Open Worktree in Byobu Tab (Priority: P1)

As a user creating a worktree inside a byobu session, I want an option to open the new worktree in a byobu tab so I can start working immediately without manual navigation.

**Why this priority**: This is the primary value of the feature and the reason it exists.

**Independent Test**: Can be fully tested by running wt-create inside a byobu session, selecting the byobu tab option, and verifying the new tab opens at the new worktree.

**Acceptance Scenarios**:

1. **Given** a byobu session and a successful worktree creation, **When** the user selects the byobu tab option, **Then** a new byobu tab opens and is focused in the same session with its working directory set to the new worktree and its tab name set to the repo name plus worktree name.
2. **Given** a byobu session and a successful worktree creation, **When** opening the byobu tab fails, **Then** the user is informed of the failure and the created worktree remains available.

---

### User Story 2 - No Byobu Option Outside Session (Priority: P2)

As a user running wt-create outside of byobu, I want the command to behave as it does today and not show byobu-specific options.

**Why this priority**: It prevents confusion and preserves existing behavior for users outside byobu.

**Independent Test**: Can be fully tested by running wt-create outside of byobu and verifying no byobu tab option is presented while other options remain available.

**Acceptance Scenarios**:

1. **Given** no active byobu session, **When** the user runs wt-create, **Then** the byobu tab option is not shown and the command completes using existing options.

---

### Edge Cases

- Worktree creation fails; the byobu tab option is not offered.
- The new worktree path contains spaces or special characters.
- A byobu session is detected but opening a new tab fails.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST detect when wt-create is executed inside a byobu session and only then offer the byobu tab option.
- **FR-002**: System MUST present the byobu tab option alongside the existing post-create options.
- **FR-003**: When the user selects the byobu tab option, system MUST open and focus a new byobu tab in the same session with the new worktree as the starting directory.
- **FR-003a**: The new byobu tab MUST be named using the repo name plus the worktree name.
- **FR-004**: If opening the byobu tab fails, system MUST inform the user and MUST keep the created worktree intact.
- **FR-005**: When wt-create is executed outside a byobu session, system MUST preserve existing behavior and MUST NOT show the byobu tab option.
- **FR-006**: If worktree creation fails, system MUST NOT offer the byobu tab option.

## Assumptions

- wt-create already provides a set of post-create options to choose from.
- Opening a byobu tab is a convenience action and is not required for a successful worktree creation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In byobu sessions, 100% of successful wt-create runs present the byobu tab option.
- **SC-002**: When users choose the byobu tab option, a new byobu tab opens to the correct worktree in at least 95% of attempts.
- **SC-003**: In non-byobu sessions, 0% of wt-create runs show the byobu tab option and existing options remain available.
- **SC-004**: At least 90% of users who choose the byobu tab option land in the new worktree without additional manual navigation.
