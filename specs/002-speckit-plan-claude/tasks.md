# Tasks: tmux Session Manager (byoman)

**Input**: Design documents from `/specs/002-speckit-plan-claude/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/cli.md

**Tests**: Not explicitly requested in specification. Basic tests included in Foundational phase.

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Based on plan.md structure:
- **Entry point**: `cmd/byoman/main.go`
- **tmux interaction**: `internal/tmux/`
- **TUI components**: `internal/tui/`
- **Messages**: `internal/strings/`
- **Logging**: `internal/logging/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and Go module setup

- [ ] T001 Create project directory structure per plan.md (cmd/byoman/, internal/tmux/, internal/tui/, internal/strings/, internal/logging/)
- [ ] T002 Initialize Go module with `go mod init` in go.mod
- [ ] T003 [P] Add dependencies to go.mod (bubbletea, bubbles, lipgloss, cobra, golang.org/x/term)
- [ ] T004 [P] Create Makefile with build, test, run, clean targets in Makefile

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

### Core Types and Utilities

- [ ] T005 [P] Create Session, Window, Pane structs with JSON tags in internal/tmux/session.go
- [ ] T006 [P] Create validation functions (ValidateName, ValidateNameUnique) with error types in internal/tmux/validation.go
- [ ] T007 [P] Create centralized user-facing messages (errors, prompts, labels) in internal/strings/strings.go
- [ ] T008 [P] Create debug logger with file output to ~/.byoman/logs/ in internal/logging/logger.go

### tmux Client Infrastructure

- [ ] T009 Create Client struct with exec.Command wrapper for tmux calls in internal/tmux/client.go
- [ ] T010 Implement tmux existence check (tmux -V) with version parsing in internal/tmux/client.go
- [ ] T011 Implement error detection (not installed, no server, permission denied) in internal/tmux/client.go
- [ ] T012 Create parser for tmux format string output (pipe-delimited) in internal/tmux/parser.go
- [ ] T013 [P] Add table-driven tests for parser in internal/tmux/parser_test.go

### CLI Framework

- [ ] T014 Create root Cobra command with flags (--list, --json, --no-color, --version) in cmd/byoman/main.go
- [ ] T015 Implement TTY detection and mode selection (TUI vs List vs JSON) in cmd/byoman/main.go
- [ ] T016 Implement exit code handling (0=success, 1=error, 2=invalid args, 127=tmux not found) in cmd/byoman/main.go

### TUI Base Structure

- [ ] T017 Create Model struct with list.Model, mode enum, styles in internal/tui/model.go
- [ ] T018 Create KeyMap with keybindings (j/k, arrows, enter, n, r, x, q, ?) in internal/tui/keys.go
- [ ] T019 Create Styles struct with lipgloss styles and AdaptiveColor in internal/tui/styles.go
- [ ] T020 Implement Init() returning initial commands in internal/tui/model.go

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - View All Sessions (Priority: P1)

**Goal**: Display list of all tmux sessions with metrics (name, status, windows, commands, time)

**Independent Test**: Run `byoman` and verify all existing tmux sessions display with correct metrics. Run `byoman --list` and `byoman --json` for non-interactive output.

### Implementation for User Story 1

- [ ] T021 [US1] Implement ListSessions() calling `tmux list-sessions -F` in internal/tmux/client.go
- [ ] T022 [US1] Implement ListPanes() for pane commands via `tmux list-panes -s -F` in internal/tmux/client.go
- [ ] T023 [US1] Parse session data (name, id, created, attached, windows) in internal/tmux/parser.go
- [ ] T024 [US1] Create SessionItem implementing list.Item interface for bubbles/list in internal/tui/model.go
- [ ] T025 [US1] Implement View() rendering session list with metrics in internal/tui/view.go
- [ ] T026 [US1] Render session row: name, status, window count, commands, relative time in internal/tui/view.go
- [ ] T027 [US1] Implement Update() handling navigation keys (j/k, arrows) in internal/tui/update.go
- [ ] T028 [US1] Implement tickCmd() for 2-second periodic refresh via tea.Tick in internal/tui/model.go
- [ ] T029 [US1] Handle empty state (no sessions) with helpful message in internal/tui/view.go
- [ ] T030 [US1] Implement --list mode text output (tab-separated columns) in cmd/byoman/main.go
- [ ] T031 [US1] Implement --json mode output matching JSON schema in cmd/byoman/main.go
- [ ] T032 [US1] Implement --no-color flag and NO_COLOR env detection in internal/tui/styles.go
- [ ] T033 [US1] Render help bar at bottom of TUI in internal/tui/view.go

**Checkpoint**: User can view all sessions in TUI, list, and JSON modes

---

## Phase 4: User Story 2 - Attach to Existing Session (Priority: P1)

**Goal**: Allow user to select and attach to any session from the list

**Independent Test**: Select a session with Enter key, verify TUI exits and user is attached to that session in tmux.

### Implementation for User Story 2

- [ ] T034 [US2] Implement AttachSession(name) command in internal/tmux/client.go
- [ ] T035 [US2] Handle Enter key to select session and set attach target in internal/tui/update.go
- [ ] T036 [US2] Return tea.Quit with selected session stored in Model in internal/tui/update.go
- [ ] T037 [US2] After TUI exits, exec tmux attach-session via syscall.Exec in cmd/byoman/main.go
- [ ] T038 [US2] Handle attaching when already inside tmux (switch-client) in cmd/byoman/main.go

**Checkpoint**: User can navigate and attach to any session

---

## Phase 5: User Story 3 - Start New Session (Priority: P2)

**Goal**: Create new tmux session with optional custom name

**Independent Test**: Press 'n', enter a name, verify new session appears in list with correct name.

### Implementation for User Story 3

- [ ] T039 [US3] Implement CreateSession(name) command using `tmux new-session -d -s` in internal/tmux/client.go
- [ ] T040 [US3] Add modeInput state and textinput.Model for name entry in internal/tui/model.go
- [ ] T041 [US3] Handle 'n' key to enter input mode for new session in internal/tui/update.go
- [ ] T042 [US3] Render input prompt "New session name:" in input mode in internal/tui/view.go
- [ ] T043 [US3] Validate name on submit (empty, invalid chars, too long) in internal/tui/update.go
- [ ] T044 [US3] Check name uniqueness before create, show error if exists in internal/tui/update.go
- [ ] T045 [US3] Handle Escape to cancel input mode in internal/tui/update.go
- [ ] T046 [US3] Refresh session list after successful create in internal/tui/update.go
- [ ] T047 [US3] Handle create without name (let tmux assign default) in internal/tui/update.go

**Checkpoint**: User can create new sessions with custom names

---

## Phase 6: User Story 4 - Rename Session (Priority: P3)

**Goal**: Rename selected session to a new name

**Independent Test**: Select session, press 'r', enter new name, verify session renamed in list.

### Implementation for User Story 4

- [ ] T048 [US4] Implement RenameSession(oldName, newName) using `tmux rename-session -t` in internal/tmux/client.go
- [ ] T049 [US4] Handle 'r' key to enter input mode for rename with current name in internal/tui/update.go
- [ ] T050 [US4] Render input prompt "Rename to:" with current name pre-filled in internal/tui/view.go
- [ ] T051 [US4] Validate new name on submit in internal/tui/update.go
- [ ] T052 [US4] Check new name uniqueness, show error if exists in internal/tui/update.go
- [ ] T053 [US4] Refresh session list after successful rename in internal/tui/update.go

**Checkpoint**: User can rename any session

---

## Phase 7: User Story 5 - Kill Session (Priority: P3)

**Goal**: Terminate selected session with confirmation

**Independent Test**: Select session, press 'x', confirm with 'y', verify session removed from list.

### Implementation for User Story 5

- [ ] T054 [US5] Implement KillSession(name) using `tmux kill-session -t` in internal/tmux/client.go
- [ ] T055 [US5] Add modeConfirm state and confirmTarget to Model in internal/tui/model.go
- [ ] T056 [US5] Handle 'x' or 'd' key to enter confirm mode in internal/tui/update.go
- [ ] T057 [US5] Render inline confirmation "Kill session 'name'? [y/N]" in internal/tui/view.go
- [ ] T058 [US5] Handle 'y'/'Y' to confirm and execute kill in internal/tui/update.go
- [ ] T059 [US5] Handle 'n'/'N'/Escape to cancel confirmation in internal/tui/update.go
- [ ] T060 [US5] Refresh session list after kill, adjust cursor if needed in internal/tui/update.go
- [ ] T061 [US5] Handle killing currently attached session gracefully in internal/tui/update.go

**Checkpoint**: User can safely kill sessions with confirmation

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Error handling, help, version, and final polish

- [ ] T062 [P] Implement '?' key to toggle help overlay in internal/tui/update.go
- [ ] T063 [P] Create help overlay view with all keybindings in internal/tui/view.go
- [ ] T064 [P] Implement version command output in cmd/byoman/main.go
- [ ] T065 Format error messages with "Error/Cause/Fix" structure per contracts/cli.md in internal/strings/strings.go
- [ ] T066 Handle stale session (killed externally) gracefully during actions in internal/tui/update.go
- [ ] T067 Handle special characters in session names in display in internal/tui/view.go
- [ ] T068 [P] Add table-driven tests for validation functions in internal/tmux/validation_test.go
- [ ] T069 Run quickstart.md validation (manual test of all documented commands)
- [ ] T070 Verify 80-column terminal compatibility in internal/tui/view.go

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational - can start after Phase 2
- **User Story 2 (Phase 4)**: Depends on US1 (needs session list to select from)
- **User Story 3 (Phase 5)**: Depends on Foundational, can parallel with US1/US2
- **User Story 4 (Phase 6)**: Depends on US1 (needs session list), can parallel with US2/US3
- **User Story 5 (Phase 7)**: Depends on US1 (needs session list), can parallel with US2/US3/US4
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies on other stories - provides foundation
- **User Story 2 (P1)**: Requires US1 (session list for selection)
- **User Story 3 (P2)**: Independent of other stories (adds to list)
- **User Story 4 (P3)**: Requires US1 (session list for selection)
- **User Story 5 (P3)**: Requires US1 (session list for selection)

### Within Each User Story

- tmux client commands before TUI integration
- Update handlers before View changes
- Core implementation before edge case handling

### Parallel Opportunities

**Phase 1 (all parallel):**
```
T003 + T004
```

**Phase 2 (parallel groups):**
```
Group 1: T005 + T006 + T007 + T008
Group 2: T009 → T010 → T011 (sequential - build on client)
Group 3: T012 → T013 (parser + tests)
Group 4: T014 → T015 → T016 (CLI sequential)
Group 5: T017 + T018 + T019 → T020 (base TUI)
```

**Phase 3-7 (within each story):**
- Tasks marked [P] can run in parallel
- Stories US3, US4, US5 can proceed in parallel after US1 foundation

**Phase 8 (parallel):**
```
T062 + T063 + T064 + T068 (independent files)
```

---

## Parallel Example: Foundational Phase

```bash
# Launch all independent type definitions together:
Task: T005 "Create Session, Window, Pane structs in internal/tmux/session.go"
Task: T006 "Create validation functions in internal/tmux/validation.go"
Task: T007 "Create centralized messages in internal/strings/strings.go"
Task: T008 "Create debug logger in internal/logging/logger.go"

# Then launch TUI base structure together:
Task: T017 "Create Model struct in internal/tui/model.go"
Task: T018 "Create KeyMap in internal/tui/keys.go"
Task: T019 "Create Styles in internal/tui/styles.go"
```

---

## Parallel Example: User Stories After Foundational

```bash
# After Foundational (Phase 2) is complete, US3/US4/US5 can run in parallel:
# Developer A: User Story 1 → User Story 2 (sequential, US2 needs US1)
# Developer B: User Story 3 (independent)
# Developer C: User Story 4 + User Story 5 (both need US1 base, but independent of each other)
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (View Sessions)
4. Complete Phase 4: User Story 2 (Attach)
5. **STOP and VALIDATE**: User can view and attach to sessions
6. Deploy/demo if ready - this is a functional MVP!

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → View sessions works → Demo
3. Add User Story 2 → Attach works → **MVP Release**
4. Add User Story 3 → Create sessions → Release
5. Add User Story 4 → Rename sessions → Release
6. Add User Story 5 → Kill sessions → Full Feature Release
7. Add Polish → Production Ready

### Suggested MVP Scope

**MVP = Phase 1 + Phase 2 + Phase 3 + Phase 4** (Tasks T001-T038)

This delivers:
- View all sessions with metrics
- Attach to any session
- List mode (--list) for scripts
- JSON mode (--json) for tooling

Users can then create/rename/kill via standard tmux commands until full features ship.

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story is independently testable after completion
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- All file paths relative to repository root
